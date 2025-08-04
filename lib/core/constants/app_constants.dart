/// Application-wide constants
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // Clock Configuration
  static const double clockSizeRatio = 0.8;
  static const double innerClockRatio = 0.7;
  static const double markerDistanceRatio = 0.92;
  static const double hourNumberDistanceRatio = 1.7;
  static const double hourFontSizeRatio = 0.05;

  // Hand Lengths (relative to radius)
  static const double hourHandLength = 0.5;
  static const double minuteHandLength = 0.7;
  static const double secondHandLength = 0.9;

  // Hand Widths
  static const double hourHandWidth = 8.0;
  static const double minuteHandWidth = 4.0;
  static const double secondHandWidth = 2.0;

  // Marker Properties
  static const double hourMarkerWidth = 1.5;
  static const double hourMarkerLength = 8.0;
  static const double minuteMarkerRadius = 2.0;

  // Center Point
  static const double centerPointRadius = 8.0;

  // Animation
  static const Duration animationDuration = Duration(seconds: 1);
  static const Duration tickInterval = Duration(seconds: 1);

  // Audio
  static const String tickSoundPath = 'tick.mp3';
  static const String audioAssetsPrefix = 'assets/';

  // Alarm Audio Files
  static const List<String> alarmSounds = [
    'AlarmShort.mp3',
    'AirRaid.mp3',
    'BurglarAlram.mp3',
    'TicTac.mp3',
  ];

  // Alarm Configuration
  static const Duration alarmDuration = Duration(minutes: 2);
  static const Duration snoozeInterval = Duration(minutes: 5);
  static const int maxAlarms = 10;

  // Layout
  static const double bottomPadding = 40.0;
  static const double bottomPaddingRatio = 0.05;

  // Alarm UI
  static const double alarmButtonSize = 56.0;
  static const double alarmItemHeight = 80.0;

  // Sound Settings
  static const bool defaultTickSoundEnabled = false;

  // Colors (could be moved to theme later)
  static const int totalMinutes = 60;
  static const int minutesPerHour = 5;
  static const int degreesPerMinute = 6;
  static const int degreesOffset = 90; // Start from 12 o'clock
}
