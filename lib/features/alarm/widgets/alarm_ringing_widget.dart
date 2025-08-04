import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/locator/service_locator.dart';
import '../../../core/services/alarm_service.dart';
import '../models/alarm_model.dart';

/// Widget displayed when an alarm is ringing
class AlarmRingingWidget extends StatelessWidget {
  final AlarmModel alarm;

  const AlarmRingingWidget({
    Key? key,
    required this.alarm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final alarmService = ServiceLocator.instance.get<IAlarmService>();

    return Container(
      color: AppColors.alarmRinging.withOpacity(0.95),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pulsing alarm icon
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.8, end: 1.2),
                duration: const Duration(milliseconds: 800),
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Icon(
                      Icons.alarm,
                      size: 120,
                      color: Colors.white,
                    ),
                  );
                },
                onEnd: () {
                  // This will cause the animation to repeat
                },
              ),

              const SizedBox(height: 32),

              // Alarm time
              Text(
                alarm.formattedTime,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              // Alarm label
              Text(
                alarm.label,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 64),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Snooze button
                  _buildActionButton(
                    icon: Icons.snooze,
                    label: 'Snooze',
                    color: AppColors.snoozeButton,
                    onPressed: () => alarmService.snoozeAlarm(alarm.id),
                  ),

                  // Stop button
                  _buildActionButton(
                    icon: Icons.stop,
                    label: 'Stop',
                    color: AppColors.stopButton,
                    onPressed: () => alarmService.stopAlarm(alarm.id),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Auto-stop countdown (optional)
              Text(
                'Alarm will stop automatically in ${AppConstants.alarmDuration.inMinutes} minutes',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(24),
          ),
          child: Icon(
            icon,
            size: 32,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// A pulsing alarm icon animation widget
class PulsingAlarmIcon extends StatefulWidget {
  const PulsingAlarmIcon({Key? key}) : super(key: key);

  @override
  State<PulsingAlarmIcon> createState() => _PulsingAlarmIconState();
}

class _PulsingAlarmIconState extends State<PulsingAlarmIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Icon(
            Icons.alarm,
            size: 120,
            color: Colors.white,
          ),
        );
      },
    );
  }
}
