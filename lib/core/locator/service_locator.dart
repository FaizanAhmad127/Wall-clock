import '../services/audio_service.dart';
import '../services/lifecycle_service.dart';
import '../services/timer_service.dart';
import '../services/alarm_service.dart';
import '../services/sound_settings_service.dart';
import '../services/storage_service.dart';

/// Service locator for dependency injection (Dependency Inversion Principle)
/// Implements a simple registry pattern for managing dependencies
class ServiceLocator {
  // Private constructor for singleton pattern
  ServiceLocator._();
  static final ServiceLocator _instance = ServiceLocator._();
  static ServiceLocator get instance => _instance;

  // Service registry
  final Map<Type, dynamic> _services = {};

  /// Register a service instance
  void register<T>(T service) {
    _services[T] = service;
  }

  /// Get a service instance
  T get<T>() {
    final service = _services[T];
    if (service == null) {
      throw Exception('Service of type $T is not registered');
    }
    return service as T;
  }

  /// Check if a service is registered
  bool isRegistered<T>() {
    return _services.containsKey(T);
  }

  /// Clear all services (useful for testing)
  void clear() {
    _services.clear();
  }

  /// Initialize all core services
  Future<void> setupServices() async {
    // Initialize storage service first as it's needed by other services
    final storageService = StorageService();
    await storageService.initialize();
    register<IStorageService>(storageService);

    // Register services with their interfaces (Dependency Inversion)
    register<IAudioService>(AudioService());
    register<ILifecycleService>(LifecycleService());
    register<ITimerService>(TimerService());

    // Register and initialize alarm service
    final alarmService = AlarmService();
    register<IAlarmService>(alarmService);
    await alarmService.initialize();

    register<ISoundSettingsService>(SoundSettingsService());
  }

  /// Dispose all services
  Future<void> disposeServices() async {
    // Dispose services that require cleanup
    if (isRegistered<IAudioService>()) {
      await get<IAudioService>().dispose();
    }

    if (isRegistered<ILifecycleService>()) {
      get<ILifecycleService>().dispose();
    }

    if (isRegistered<ITimerService>()) {
      get<ITimerService>().dispose();
    }

    if (isRegistered<IAlarmService>()) {
      await get<IAlarmService>().dispose();
    }

    if (isRegistered<ISoundSettingsService>()) {
      await get<ISoundSettingsService>().dispose();
    }

    if (isRegistered<IStorageService>()) {
      await get<IStorageService>().dispose();
    }

    clear();
  }
}
