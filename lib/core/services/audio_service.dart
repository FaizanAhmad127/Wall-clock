import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import '../constants/app_constants.dart';

/// Interface for audio operations (Dependency Inversion Principle)
abstract class IAudioService {
  Future<void> initialize();
  Future<void> playTickSound();
  Future<void> dispose();
}

/// Concrete implementation of audio service
class AudioService implements IAudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioCache _audioCache = AudioCache(prefix: AppConstants.audioAssetsPrefix);
  Uri? _tickSoundPath;

  @override
  Future<void> initialize() async {
    try {
      _tickSoundPath = await _audioCache.load(AppConstants.tickSoundPath);
    } catch (e) {
      // Log error or handle gracefully
      print('Failed to load audio: $e');
    }
  }

  @override
  Future<void> playTickSound() async {
    if (_tickSoundPath == null) return;
    
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(
        DeviceFileSource(_tickSoundPath!.path),
        mode: PlayerMode.lowLatency,
      );
    } catch (e) {
      // Log error or handle gracefully
      print('Error playing tick sound: $e');
    }
  }

  @override
  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}