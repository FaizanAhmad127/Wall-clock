import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import '../constants/app_constants.dart';
import '../locator/service_locator.dart';
import 'storage_service.dart';
import '../../features/alarm/models/alarm_model.dart';

/// Interface for alarm operations (Dependency Inversion Principle)
abstract class IAlarmService {
  Stream<List<AlarmModel>> get alarmsStream;
  Stream<AlarmModel?> get ringingAlarmStream;

  Future<void> initialize();
  Future<void> addAlarm(AlarmModel alarm);
  Future<void> updateAlarm(AlarmModel alarm);
  Future<void> deleteAlarm(String alarmId);
  Future<void> toggleAlarm(String alarmId);

  Future<void> snoozeAlarm(String alarmId);
  Future<void> stopAlarm(String alarmId);

  void checkAlarms(DateTime currentTime);
  List<AlarmModel> getCurrentAlarms(); // Add method to get current state
  Future<void> dispose();
}

/// Concrete implementation of alarm service
class AlarmService implements IAlarmService {
  final AudioPlayer _alarmPlayer = AudioPlayer();
  final List<AlarmModel> _alarms = [];

  final StreamController<List<AlarmModel>> _alarmsController =
      StreamController<List<AlarmModel>>.broadcast();
  final StreamController<AlarmModel?> _ringingAlarmController =
      StreamController<AlarmModel?>.broadcast();

  AlarmModel? _currentRingingAlarm;
  Timer? _alarmDurationTimer;
  bool _isInitialized = false;

  // Keep track of the latest alarms state
  List<AlarmModel> _latestAlarms = [];

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load saved alarms from storage
      final storageService = ServiceLocator.instance.get<IStorageService>();
      final savedAlarms = await storageService.loadAlarms();

      // Reset ringing/snoozed states on app restart (these are transient states)
      final cleanedAlarms = savedAlarms
          .map((alarm) => alarm.copyWith(
                isRinging: false,
                isSnoozed: false,
                snoozeUntil: null,
              ))
          .toList();

      _alarms.clear();
      _alarms.addAll(cleanedAlarms);
      _isInitialized = true;

      // Notify listeners of loaded alarms
      _notifyAlarmsChanged();
    } catch (e) {
      print('AlarmService: Error initializing: $e');
      _isInitialized = true;
    }
  }

  @override
  Stream<List<AlarmModel>> get alarmsStream async* {
    // Ensure service is initialized
    if (!_isInitialized) {
      await initialize();
    }

    // Immediately emit current state
    yield List.from(_alarms);
    // Then yield all future updates
    yield* _alarmsController.stream;
  }

  @override
  Stream<AlarmModel?> get ringingAlarmStream => _ringingAlarmController.stream;

  @override
  List<AlarmModel> getCurrentAlarms() {
    return List.from(_alarms);
  }

  @override
  Future<void> addAlarm(AlarmModel alarm) async {
    _alarms.add(alarm);
    await _notifyAlarmsChanged();
  }

  @override
  Future<void> updateAlarm(AlarmModel alarm) async {
    final index = _alarms.indexWhere((a) => a.id == alarm.id);
    if (index != -1) {
      _alarms[index] = alarm;
      await _notifyAlarmsChanged();
    }
  }

  @override
  Future<void> deleteAlarm(String alarmId) async {
    _alarms.removeWhere((alarm) => alarm.id == alarmId);
    await _notifyAlarmsChanged();
  }

  @override
  Future<void> toggleAlarm(String alarmId) async {
    final index = _alarms.indexWhere((alarm) => alarm.id == alarmId);
    if (index != -1) {
      _alarms[index] = _alarms[index].copyWith(
        isActive: !_alarms[index].isActive,
      );
      await _notifyAlarmsChanged();
    }
  }

  @override
  void checkAlarms(DateTime currentTime) {
    for (int i = 0; i < _alarms.length; i++) {
      final alarm = _alarms[i];
      if (alarm.shouldRing(currentTime) && _currentRingingAlarm == null) {
        _triggerAlarm(alarm);
        break; // Only trigger one alarm at a time
      }
    }
  }

  @override
  Future<void> snoozeAlarm(String alarmId) async {
    if (_currentRingingAlarm?.id == alarmId) {
      await _stopAlarmSound();

      final snoozedAlarm = _currentRingingAlarm!.copyWith(
        isRinging: false,
        isSnoozed: true,
        snoozeUntil: DateTime.now().add(AppConstants.snoozeInterval),
      );

      await updateAlarm(snoozedAlarm);
      _currentRingingAlarm = null;
      _ringingAlarmController.add(null);
    }
  }

  @override
  Future<void> stopAlarm(String alarmId) async {
    if (_currentRingingAlarm?.id == alarmId) {
      await _stopAlarmSound();

      // If it's a one-time alarm, deactivate it
      final alarm = _currentRingingAlarm!;
      final shouldDeactivate = alarm.repeatDays.every((day) => !day);

      final stoppedAlarm = alarm.copyWith(
        isRinging: false,
        isSnoozed: false,
        snoozeUntil: null,
        isActive: !shouldDeactivate,
      );

      await updateAlarm(stoppedAlarm);
      _currentRingingAlarm = null;
      _ringingAlarmController.add(null);
    }
  }

  Future<void> _triggerAlarm(AlarmModel alarm) async {
    try {
      // Update alarm state to ringing
      final ringingAlarm = alarm.copyWith(
        isRinging: true,
        isSnoozed: false,
        snoozeUntil: null,
      );
      await updateAlarm(ringingAlarm);

      _currentRingingAlarm = ringingAlarm;
      _ringingAlarmController.add(ringingAlarm);

      // Play alarm sound
      await _playAlarmSound(alarm.soundPath);

      // Auto-stop alarm after duration
      _alarmDurationTimer = Timer(AppConstants.alarmDuration, () {
        stopAlarm(alarm.id);
      });
    } catch (e) {
      print('AlarmService: Error triggering alarm: $e');
    }
  }

  Future<void> _playAlarmSound(String soundPath) async {
    try {
      await _alarmPlayer.stop();
      await _alarmPlayer.setReleaseMode(ReleaseMode.loop);
      await _alarmPlayer.play(AssetSource(soundPath));
    } catch (e) {
      print('AlarmService: Error playing alarm sound: $e');
    }
  }

  Future<void> _stopAlarmSound() async {
    try {
      _alarmDurationTimer?.cancel();
      await _alarmPlayer.stop();
    } catch (e) {
      print('AlarmService: Error stopping alarm sound: $e');
    }
  }

  Future<void> _notifyAlarmsChanged() async {
    _latestAlarms = List.from(_alarms);

    // Save to persistent storage
    try {
      final storageService = ServiceLocator.instance.get<IStorageService>();
      await storageService.saveAlarms(_latestAlarms);
    } catch (e) {
      print('AlarmService: Error saving alarms: $e');
    }

    // Notify stream listeners
    if (!_alarmsController.isClosed) {
      _alarmsController.add(_latestAlarms);
    }
  }

  @override
  Future<void> dispose() async {
    await _stopAlarmSound();
    await _alarmPlayer.dispose();
    await _alarmsController.close();
    await _ringingAlarmController.close();
  }
}
