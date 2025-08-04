import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/clock_data.dart';

/// Widget responsible for displaying the digital clock (Single Responsibility)
class DigitalClockWidget extends StatelessWidget {
  final ClockData clockData;

  const DigitalClockWidget({
    Key? key,
    required this.clockData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeParts = clockData.formattedTime.split(' ');
    final time = timeParts[0];
    final period = timeParts[1];

    final timeComponents = time.split(':');
    final hour = timeComponents[0];
    final minute = timeComponents[1];
    final second = timeComponents[2];

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: hour,
            style: const TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.bold,
              color: AppColors.digitalClockText,
            ),
          ),
          const TextSpan(
            text: ':',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.normal,
              color: AppColors.digitalClockText,
            ),
          ),
          TextSpan(
            text: minute,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w600,
              color: AppColors.digitalClockText,
            ),
          ),
          const TextSpan(
            text: ':',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.normal,
              color: AppColors.digitalClockText,
            ),
          ),
          TextSpan(
            text: second,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.normal,
              color: AppColors.digitalClockText,
            ),
          ),
          TextSpan(
            text: ' $period',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.normal,
              color: AppColors.digitalClockText,
            ),
          ),
        ],
      ),
    );
  }
}
