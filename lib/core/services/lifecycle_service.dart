import 'package:flutter/widgets.dart';

/// Interface for lifecycle management (Single Responsibility Principle)
abstract class ILifecycleService {
  void initialize(
      {required VoidCallback onForeground, required VoidCallback onBackground});
  void dispose();
  bool get isInForeground;
}

/// Concrete implementation of lifecycle service
class LifecycleService extends WidgetsBindingObserver
    implements ILifecycleService {
  bool _isInForeground = true;
  VoidCallback? _onForeground;
  VoidCallback? _onBackground;

  @override
  void initialize(
      {required VoidCallback onForeground,
      required VoidCallback onBackground}) {
    _onForeground = onForeground;
    _onBackground = onBackground;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  bool get isInForeground => _isInForeground;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _isInForeground = true;
        _onForeground?.call();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _isInForeground = false;
        _onBackground?.call();
        break;
    }
  }
}
