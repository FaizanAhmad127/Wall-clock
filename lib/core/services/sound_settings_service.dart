import 'dart:async';
import '../constants/app_constants.dart';

/// Interface for sound settings management (Dependency Inversion Principle)
abstract class ISoundSettingsService {
  Stream<bool> get tickSoundEnabledStream;
  bool get isTickSoundEnabled;

  Future<void> toggleTickSound();
  Future<void> setTickSound(bool enabled);
  Future<void> dispose();
}

/// Concrete implementation of sound settings service
class SoundSettingsService implements ISoundSettingsService {
  bool _tickSoundEnabled = AppConstants.defaultTickSoundEnabled;

  final StreamController<bool> _tickSoundController =
      StreamController<bool>.broadcast();

  @override
  Stream<bool> get tickSoundEnabledStream async* {
    // Immediately emit current state
    yield _tickSoundEnabled;
    // Then yield all future updates
    yield* _tickSoundController.stream;
  }

  @override
  bool get isTickSoundEnabled => _tickSoundEnabled;

  @override
  Future<void> toggleTickSound() async {
    _tickSoundEnabled = !_tickSoundEnabled;
    _notifyStateChanged();
  }

  @override
  Future<void> setTickSound(bool enabled) async {
    if (_tickSoundEnabled != enabled) {
      _tickSoundEnabled = enabled;
      _notifyStateChanged();
    }
  }

  void _notifyStateChanged() {
    if (!_tickSoundController.isClosed) {
      _tickSoundController.add(_tickSoundEnabled);
    }
  }

  @override
  Future<void> dispose() async {
    await _tickSoundController.close();
  }
}
