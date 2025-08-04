import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/locator/service_locator.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/lifecycle_service.dart';
import '../../../core/services/timer_service.dart';
import '../../../core/services/alarm_service.dart';
import '../../../core/services/sound_settings_service.dart';
import '../models/clock_data.dart';
import '../../alarm/models/alarm_model.dart';
import '../../alarm/widgets/alarm_list_widget.dart';
import '../../alarm/widgets/alarm_ringing_widget.dart';
import 'analog_clock_widget.dart';
import 'digital_clock_widget.dart';
import 'sound_toggle_widget.dart';

/// Main clock screen that orchestrates all clock functionality
/// Follows Single Responsibility Principle - manages clock display and coordination
class ClockScreen extends StatefulWidget {
  const ClockScreen({Key? key}) : super(key: key);

  @override
  State<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  ClockData _currentTime = ClockData.now();
  bool _showAlarms = false;

  // Service dependencies (Dependency Inversion Principle)
  late final IAudioService _audioService;
  late final ILifecycleService _lifecycleService;
  late final ITimerService _timerService;
  late final IAlarmService _alarmService;
  late final ISoundSettingsService _soundSettingsService;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _setupAnimation();
    _setupAudio();
  }

  /// Initialize all required services from service locator
  void _initializeServices() {
    final serviceLocator = ServiceLocator.instance;
    _audioService = serviceLocator.get<IAudioService>();
    _lifecycleService = serviceLocator.get<ILifecycleService>();
    _timerService = serviceLocator.get<ITimerService>();
    _alarmService = serviceLocator.get<IAlarmService>();
    _soundSettingsService = serviceLocator.get<ISoundSettingsService>();
  }

  /// Setup animation controller for smooth updates
  void _setupAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.animationDuration,
    )..repeat();
  }

  /// Setup audio and lifecycle management
  void _setupAudio() {
    // Initialize audio service
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _audioService.initialize();
    });

    // Setup lifecycle management
    _lifecycleService.initialize(
      onForeground: _startTicking,
      onBackground: _stopTicking,
    );

    // Start ticking
    _startTicking();
  }

  /// Start the ticking process (when app is in foreground)
  void _startTicking() {
    if (_lifecycleService.isInForeground) {
      _timerService.startTicking(_onTick);
    }
  }

  /// Stop the ticking process (when app goes to background)
  void _stopTicking() {
    _timerService.stopTicking();
  }

  /// Handle each tick - update time, play sound if enabled, and check alarms
  void _onTick() {
    if (_lifecycleService.isInForeground) {
      setState(() {
        _currentTime = ClockData.now();
      });

      // Only play tick sound if enabled
      if (_soundSettingsService.isTickSoundEnabled) {
        _audioService.playTickSound();
      }

      // Check for alarms that should ring
      _alarmService.checkAlarms(_currentTime.dateTime);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _lifecycleService.dispose();
    _timerService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Stack(
        children: [
          // Main clock display
          if (!_showAlarms) ...[
            // Analog Clock
            Center(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return AnalogClockWidget(clockData: _currentTime);
                },
              ),
            ),
            // Digital Clock
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: screenHeight * AppConstants.bottomPaddingRatio,
                ),
                child: DigitalClockWidget(clockData: _currentTime),
              ),
            ),
          ],

          // Alarm list overlay
          if (_showAlarms)
            Container(
              color: AppColors.scaffoldBackground.withOpacity(0.95),
              child: SafeArea(
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Alarms',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                setState(() => _showAlarms = false),
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                    // Alarm list
                    const Expanded(
                      child: SingleChildScrollView(
                        child: AlarmListWidget(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Floating action buttons
          Positioned(
            right: 16,
            top: MediaQuery.of(context).padding.top + 16,
            child: Row(
              spacing: 4,
              children: [
                // Sound toggle button
                const SoundToggleWidget(),

                const SizedBox(height: 16),

                // Alarm button
                FloatingActionButton(
                  heroTag: "alarm",
                  backgroundColor: AppColors.alarmButtonBackground,
                  onPressed: () => setState(() => _showAlarms = !_showAlarms),
                  child: Icon(
                    _showAlarms ? Icons.schedule : Icons.alarm,
                    color: AppColors.alarmButtonIcon,
                  ),
                ),

                if (_showAlarms) ...[
                  const SizedBox(height: 16),
                  // Add alarm button
                  FloatingActionButton(
                    heroTag: "add_alarm",
                    backgroundColor: AppColors.alarmActive,
                    onPressed: _showAddAlarmDialog,
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ],
            ),
          ),

          // Alarm ringing overlay
          StreamBuilder<AlarmModel?>(
            stream: _alarmService.ringingAlarmStream,
            builder: (context, snapshot) {
              final ringingAlarm = snapshot.data;
              if (ringingAlarm != null) {
                return AlarmRingingWidget(alarm: ringingAlarm);
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  void _showAddAlarmDialog() {
    showDialog(
      context: context,
      builder: (context) => const AlarmDialogWidget(),
    );
  }
}
