import 'package:flutter/material.dart';
import 'dart:math';
import '../../../core/constants/app_constants.dart';
import '../models/clock_data.dart';
import '../painters/clock_painter.dart';

/// Widget responsible for displaying the analog clock (Single Responsibility)
class AnalogClockWidget extends StatelessWidget {
  final ClockData clockData;

  const AnalogClockWidget({
    Key? key,
    required this.clockData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final clockSize =
        min(screenSize.width, screenSize.height) * AppConstants.clockSizeRatio;

    return CustomPaint(
      painter: ClockPainter(clockData: clockData),
      size: Size(clockSize, clockSize),
    );
  }
}
