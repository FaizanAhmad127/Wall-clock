/// Immutable data model representing current time
class ClockData {
  final int hour;
  final int minute;
  final int second;
  final DateTime dateTime;

  const ClockData({
    required this.hour,
    required this.minute,
    required this.second,
    required this.dateTime,
  });

  /// Factory constructor to create ClockData from DateTime
  factory ClockData.fromDateTime(DateTime dateTime) {
    return ClockData(
      hour: dateTime.hour,
      minute: dateTime.minute,
      second: dateTime.second,
      dateTime: dateTime,
    );
  }

  /// Get current time as ClockData
  factory ClockData.now() {
    return ClockData.fromDateTime(DateTime.now());
  }

  /// Get 12-hour format hour
  int get hour12 => hour % 12 == 0 ? 12 : hour % 12;

  /// Get AM/PM indicator
  String get period => hour >= 12 ? 'PM' : 'am';

  /// Get formatted time string
  String get formattedTime =>
      "${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')} $period";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClockData &&
          runtimeType == other.runtimeType &&
          hour == other.hour &&
          minute == other.minute &&
          second == other.second;

  @override
  int get hashCode => hour.hashCode ^ minute.hashCode ^ second.hashCode;

  @override
  String toString() =>
      'ClockData(hour: $hour, minute: $minute, second: $second)';
}
