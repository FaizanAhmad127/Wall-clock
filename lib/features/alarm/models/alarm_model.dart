import 'package:flutter/material.dart';

/// Immutable alarm data model
class AlarmModel {
  final String id;
  final TimeOfDay time;
  final String label;
  final bool isActive;
  final List<bool> repeatDays; // [Mon, Tue, Wed, Thu, Fri, Sat, Sun]
  final String soundPath;
  final DateTime? nextRingTime;
  final bool isRinging;
  final bool isSnoozed;
  final DateTime? snoozeUntil;

  const AlarmModel({
    required this.id,
    required this.time,
    this.label = 'Alarm',
    this.isActive = true,
    this.repeatDays = const [false, false, false, false, false, false, false],
    this.soundPath = 'AlarmShort.mp3',
    this.nextRingTime,
    this.isRinging = false,
    this.isSnoozed = false,
    this.snoozeUntil,
  });

  /// Create a copy with modified properties
  AlarmModel copyWith({
    String? id,
    TimeOfDay? time,
    String? label,
    bool? isActive,
    List<bool>? repeatDays,
    String? soundPath,
    DateTime? nextRingTime,
    bool? isRinging,
    bool? isSnoozed,
    DateTime? snoozeUntil,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      time: time ?? this.time,
      label: label ?? this.label,
      isActive: isActive ?? this.isActive,
      repeatDays: repeatDays ?? this.repeatDays,
      soundPath: soundPath ?? this.soundPath,
      nextRingTime: nextRingTime ?? this.nextRingTime,
      isRinging: isRinging ?? this.isRinging,
      isSnoozed: isSnoozed ?? this.isSnoozed,
      snoozeUntil: snoozeUntil ?? this.snoozeUntil,
    );
  }

  /// Check if alarm should ring at given time
  bool shouldRing(DateTime currentTime) {
    if (!isActive || isRinging) return false;

    // Check if currently snoozed
    if (isSnoozed && snoozeUntil != null) {
      return currentTime.isAfter(snoozeUntil!);
    }

    // Check if time matches (within same minute)
    final alarmDateTime = _getNextAlarmDateTime(currentTime);
    return alarmDateTime != null &&
        currentTime.hour == alarmDateTime.hour &&
        currentTime.minute == alarmDateTime.minute &&
        currentTime.second == 0; // Trigger only at start of minute
  }

  /// Get next scheduled alarm time
  DateTime? _getNextAlarmDateTime(DateTime currentTime) {
    if (!isActive) return null;

    final today =
        DateTime(currentTime.year, currentTime.month, currentTime.day);
    final alarmToday =
        DateTime(today.year, today.month, today.day, time.hour, time.minute);

    // If no repeat days set, it's a one-time alarm
    if (repeatDays.every((day) => !day)) {
      if (alarmToday.isAfter(currentTime)) {
        return alarmToday;
      } else {
        return alarmToday.add(const Duration(days: 1));
      }
    }

    // Check for repeating alarms
    for (int i = 0; i < 7; i++) {
      final checkDate = today.add(Duration(days: i));
      final weekday = (checkDate.weekday - 1) % 7; // Convert to 0-6 (Mon-Sun)

      if (repeatDays[weekday]) {
        final alarmTime = DateTime(checkDate.year, checkDate.month,
            checkDate.day, time.hour, time.minute);
        if (alarmTime.isAfter(currentTime)) {
          return alarmTime;
        }
      }
    }

    return null;
  }

  /// Get formatted time string
  String get formattedTime {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  /// Get repeat days string
  String get repeatDaysText {
    if (repeatDays.every((day) => !day)) return 'Once';
    if (repeatDays.every((day) => day)) return 'Daily';

    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final activeDays = <String>[];

    for (int i = 0; i < repeatDays.length; i++) {
      if (repeatDays[i]) {
        activeDays.add(dayNames[i]);
      }
    }

    return activeDays.join(', ');
  }

  /// Convert alarm to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timeHour': time.hour,
      'timeMinute': time.minute,
      'label': label,
      'isActive': isActive,
      'repeatDays': repeatDays,
      'soundPath': soundPath,
      'nextRingTime': nextRingTime?.millisecondsSinceEpoch,
      'isRinging': isRinging,
      'isSnoozed': isSnoozed,
      'snoozeUntil': snoozeUntil?.millisecondsSinceEpoch,
    };
  }

  /// Create alarm from JSON data
  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      id: json['id'] as String,
      time: TimeOfDay(
        hour: json['timeHour'] as int,
        minute: json['timeMinute'] as int,
      ),
      label: json['label'] as String? ?? 'Alarm',
      isActive: json['isActive'] as bool? ?? true,
      repeatDays: (json['repeatDays'] as List<dynamic>?)
              ?.map((e) => e as bool)
              .toList() ??
          [false, false, false, false, false, false, false],
      soundPath: json['soundPath'] as String? ?? 'AlarmShort.mp3',
      nextRingTime: json['nextRingTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['nextRingTime'] as int)
          : null,
      isRinging: json['isRinging'] as bool? ?? false,
      isSnoozed: json['isSnoozed'] as bool? ?? false,
      snoozeUntil: json['snoozeUntil'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['snoozeUntil'] as int)
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlarmModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'AlarmModel(id: $id, time: $formattedTime, active: $isActive)';
}
