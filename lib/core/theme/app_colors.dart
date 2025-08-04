import 'package:flutter/material.dart';

/// Application color scheme
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Background Colors
  static const Color scaffoldBackground = Colors.grey;
  static const Color clockBackground = Colors.white;
  static Color clockBorder = Colors.grey.shade300;
  static Color clockFaceStart = Colors.white;
  static Color clockFaceEnd = Colors.grey.shade300;

  // Clock Elements
  static const Color markerColor = Colors.orange;
  static const Color hourNumbers = Colors.black87;
  static const Color hourHand = Colors.black;
  static const Color minuteHand = Colors.black;
  static const Color secondHand = Colors.red;
  static const Color centerPoint = Colors.black;

  // Digital Clock
  static const Color digitalClockText = Colors.white;

  // Alarm Colors
  static const Color alarmActive = Colors.green;
  static const Color alarmInactive = Colors.grey;
  static const Color alarmButtonBackground = Colors.orange;
  static const Color alarmButtonIcon = Colors.white;
  static const Color alarmRinging = Colors.red;
  static const Color snoozeButton = Colors.amber;
  static const Color stopButton = Colors.red;

  // Sound Toggle Colors
  static const Color soundOnButton = Colors.green;
  static const Color soundOffButton = Colors.red;
  static const Color soundButtonIcon = Colors.white;

  // Shadow
  static Color shadowColor = Colors.black.withOpacity(0.1);
}
