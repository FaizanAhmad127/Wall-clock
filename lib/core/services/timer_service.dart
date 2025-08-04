import 'dart:async';
import 'package:flutter/widgets.dart';
import '../constants/app_constants.dart';

/// Interface for timer operations (Single Responsibility Principle)
abstract class ITimerService {
  void startTicking(VoidCallback onTick);
  void stopTicking();
  bool get isRunning;
  void dispose();
}

/// Concrete implementation of timer service
class TimerService implements ITimerService {
  Timer? _timer;
  bool _isRunning = false;

  @override
  void startTicking(VoidCallback onTick) {
    stopTicking(); // Ensure no duplicate timers

    _timer = Timer.periodic(AppConstants.tickInterval, (timer) {
      onTick();
    });
    _isRunning = true;
  }

  @override
  void stopTicking() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }

  @override
  bool get isRunning => _isRunning;

  @override
  void dispose() {
    stopTicking();
  }
}
