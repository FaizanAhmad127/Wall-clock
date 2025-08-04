import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../models/clock_data.dart';

/// Custom painter for drawing the analog clock (Single Responsibility Principle)
class ClockPainter extends CustomPainter {
  final ClockData clockData;

  ClockPainter({required this.clockData});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 1.8, size.height);

    _drawClockBackground(canvas, center, radius);
    _drawClockFace(canvas, center, radius);
    _drawMarkers(canvas, center, radius);
    _drawHands(canvas, center, radius);
    _drawCenterPoint(canvas, center);
  }

  /// Draw the outer white background circle
  void _drawClockBackground(Canvas canvas, Offset center, double radius) {
    final backgroundPaint = Paint()
      ..color = AppColors.clockBackground
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw border
    final borderPaint = Paint()
      ..color = AppColors.clockBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, borderPaint);
  }

  /// Draw the inner clock face with gradient
  void _drawClockFace(Canvas canvas, Offset center, double radius) {
    final innerRadius = radius * AppConstants.innerClockRatio;
    final facePaint = Paint()
      ..shader = RadialGradient(
        colors: [AppColors.clockFaceStart, AppColors.clockFaceEnd],
      ).createShader(Rect.fromCircle(center: center, radius: innerRadius));
    canvas.drawCircle(center, innerRadius, facePaint);
  }

  /// Draw hour markers, minute markers, and numbers
  void _drawMarkers(Canvas canvas, Offset center, double radius) {
    final markerRadius = radius * AppConstants.markerDistanceRatio;

    _drawHourMarkers(canvas, center, radius, markerRadius);
    _drawMinuteMarkers(canvas, center, markerRadius);
    _drawHourNumbers(canvas, center, radius, markerRadius);
  }

  /// Draw hour markers (thick orange lines)
  void _drawHourMarkers(
      Canvas canvas, Offset center, double radius, double markerRadius) {
    final hourMarkerPaint = Paint()
      ..color = AppColors.markerColor
      ..strokeWidth = AppConstants.hourMarkerWidth
      ..strokeCap = StrokeCap.round;

    for (int i = 0;
        i < AppConstants.totalMinutes;
        i += AppConstants.minutesPerHour) {
      final angle =
          (i * AppConstants.degreesPerMinute - AppConstants.degreesOffset) *
              pi /
              180;

      final outerPoint = Offset(
        center.dx + markerRadius * cos(angle),
        center.dy + markerRadius * sin(angle),
      );
      final innerPoint = Offset(
        center.dx + (markerRadius - AppConstants.hourMarkerLength) * cos(angle),
        center.dy + (markerRadius - AppConstants.hourMarkerLength) * sin(angle),
      );

      canvas.drawLine(outerPoint, innerPoint, hourMarkerPaint);
    }
  }

  /// Draw minute markers (small orange dots)
  void _drawMinuteMarkers(Canvas canvas, Offset center, double markerRadius) {
    final minuteMarkerPaint = Paint()
      ..color = AppColors.markerColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < AppConstants.totalMinutes; i++) {
      if (i % AppConstants.minutesPerHour != 0) {
        // Skip hour positions
        final angle =
            (i * AppConstants.degreesPerMinute - AppConstants.degreesOffset) *
                pi /
                180;
        final dotCenter = Offset(
          center.dx + markerRadius * cos(angle),
          center.dy + markerRadius * sin(angle),
        );
        canvas.drawCircle(
            dotCenter, AppConstants.minuteMarkerRadius, minuteMarkerPaint);
      }
    }
  }

  /// Draw hour numbers
  void _drawHourNumbers(
      Canvas canvas, Offset center, double radius, double markerRadius) {
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    final numberRadius =
        markerRadius - AppConstants.hourNumberDistanceRatio * radius;

    // Draw numbers for each hour marker (multiples of 5)
    for (int i = 0; i < 60; i += 5) {
      final angle =
          (i * 6 - 270) * pi / 180; // Same angle calculation as hour markers
      final numberX = center.dx + numberRadius * cos(angle);
      final numberY = center.dy + numberRadius * sin(angle);

      // Convert minute position to hour number (0->12, 5->1, 10->2, etc.)
      String displayNumber;

      displayNumber = '$i'; // 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55

      textPainter.text = TextSpan(
        text: displayNumber,
        style: TextStyle(
          color: AppColors.hourNumbers,
          fontSize: radius * AppConstants.hourFontSizeRatio,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();

      final textOffset = Offset(
        numberX - textPainter.width / 2,
        numberY - textPainter.height / 2,
      );
      textPainter.paint(canvas, textOffset);
    }
  }

  /// Draw clock hands
  void _drawHands(Canvas canvas, Offset center, double radius) {
    final innerRadius = radius * AppConstants.innerClockRatio;

    _drawHourHand(canvas, center, innerRadius);
    _drawMinuteHand(canvas, center, innerRadius);
    _drawSecondHand(canvas, center, innerRadius);
  }

  /// Draw hour hand
  void _drawHourHand(Canvas canvas, Offset center, double radius) {
    final hourHandPaint = Paint()
      ..color = AppColors.hourHand
      ..strokeWidth = AppConstants.hourHandWidth
      ..strokeCap = StrokeCap.round;

    final hourAngle =
        (clockData.hour % 12 * 30 + clockData.minute * 0.5) * pi / 180 - pi / 2;
    final hourHandEnd = Offset(
      center.dx + radius * AppConstants.hourHandLength * cos(hourAngle),
      center.dy + radius * AppConstants.hourHandLength * sin(hourAngle),
    );
    canvas.drawLine(center, hourHandEnd, hourHandPaint);
  }

  /// Draw minute hand
  void _drawMinuteHand(Canvas canvas, Offset center, double radius) {
    final minuteHandPaint = Paint()
      ..color = AppColors.minuteHand
      ..strokeWidth = AppConstants.minuteHandWidth
      ..strokeCap = StrokeCap.round;

    final minuteAngle = clockData.minute * 6 * pi / 180 - pi / 2;
    final minuteHandEnd = Offset(
      center.dx + radius * AppConstants.minuteHandLength * cos(minuteAngle),
      center.dy + radius * AppConstants.minuteHandLength * sin(minuteAngle),
    );
    canvas.drawLine(center, minuteHandEnd, minuteHandPaint);
  }

  /// Draw second hand
  void _drawSecondHand(Canvas canvas, Offset center, double radius) {
    final secondHandPaint = Paint()
      ..color = AppColors.secondHand
      ..strokeWidth = AppConstants.secondHandWidth
      ..strokeCap = StrokeCap.round;

    final secondAngle = clockData.second * 6 * pi / 180 - pi / 2;
    final secondHandEnd = Offset(
      center.dx + radius * AppConstants.secondHandLength * cos(secondAngle),
      center.dy + radius * AppConstants.secondHandLength * sin(secondAngle),
    );
    canvas.drawLine(center, secondHandEnd, secondHandPaint);
  }

  /// Draw center point
  void _drawCenterPoint(Canvas canvas, Offset center) {
    final centerPointPaint = Paint()..color = AppColors.centerPoint;
    canvas.drawCircle(center, AppConstants.centerPointRadius, centerPointPaint);
  }

  @override
  bool shouldRepaint(ClockPainter oldDelegate) {
    return oldDelegate.clockData != clockData;
  }
}
