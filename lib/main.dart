import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey,
        body: Center(
          child: Clock(),
        ),
      ),
    );
  }
}

class Clock extends StatefulWidget {
  @override
  _ClockState createState() => _ClockState();
}

class _ClockState extends State<Clock> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioCache _audioCache = AudioCache(prefix: 'assets/');
  late Uri filePath;
  late Timer _timer;
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      // Preload the audio file
      filePath = await _audioCache.load('tick.mp3');
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _playTickSound();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    _timer.cancel();
    super.dispose();
  }

  Future<void> _playTickSound() async {
    try {
      await _audioPlayer.stop(); // Ensure the player is stopped before playing
      await _audioPlayer.play(DeviceFileSource(filePath.path),
          mode: PlayerMode.lowLatency);
    } catch (e) {
      debugPrint('Error playing tick sound: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    final double markerRadius = 0.19 * h; // Radius of the circle
    final double whiteCircleRadius = 0.22 * h; // Radius of the markers
    final double greyCircleRadius = 0.34 * h; // Center X of the circle
    final double centerX = 0.439 * w; // Center X of the circle
    final double centerY = 0.20 * h; // Center Y of the circle

    List<Widget> dotMarkers = [];
    for (int i = 0; i < 60; i++) {
      double angle =
          (i * 6 - 90) * pi / 180; // Adjust angle to start from 12 o'clock

      double x = centerX + markerRadius * cos(angle); // Adjust for marker width
      double y =
          centerY + markerRadius * sin(angle); // Adjust for marker height
      String figure = i % 5 == 0 ? "$i" : "";
      dotMarkers.add(Positioned(
        left: x,
        top: y,
        child: Transform.rotate(
          angle: angle + pi / 2, // Rotate by 90 degrees plus the angle
          child: Column(
            children: [
              Container(
                height: i % 5 == 0 ? 10 : 5, // Larger markers for hours
                width: 2, // Same width for all markers
                decoration: BoxDecoration(
                  color: Colors.orange,
                  shape: i % 5 == 0 ? BoxShape.rectangle : BoxShape.circle,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                figure,
                style: const TextStyle(fontSize: 12),
              )
            ],
          ),
        ),
      ));
    }

    return Stack(
      children: [
        Center(
          child: CircleAvatar(
            radius: whiteCircleRadius,
            backgroundColor: Colors.white,
            child: Stack(
              children: [...dotMarkers],
            ),
          ),
        ),
        Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: ClockPainter(),
                size: Size(greyCircleRadius, greyCircleRadius),
              );
            },
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: DigitalClock(),
          ),
        ),
      ],
    );
  }
}

class ClockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);

    final dateTime = DateTime.now();

    // Draw clock face
    final facePaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white, Colors.grey.shade300],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, facePaint);

    // Draw hour hand
    final hourHandPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    final hourHandX = center.dx +
        radius *
            0.5 *
            cos((dateTime.hour * 30 + dateTime.minute * 0.5) * pi / 180 -
                pi / 2);
    final hourHandY = center.dy +
        radius *
            0.5 *
            sin((dateTime.hour * 30 + dateTime.minute * 0.5) * pi / 180 -
                pi / 2);
    canvas.drawLine(center, Offset(hourHandX, hourHandY), hourHandPaint);

    // Draw minute hand
    final minuteHandPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final minuteHandX =
        center.dx + radius * 0.7 * cos(dateTime.minute * 6 * pi / 180 - pi / 2);
    final minuteHandY =
        center.dy + radius * 0.7 * sin(dateTime.minute * 6 * pi / 180 - pi / 2);
    canvas.drawLine(center, Offset(minuteHandX, minuteHandY), minuteHandPaint);

    // Draw second hand
    final secondHandPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final secondHandX =
        center.dx + radius * 0.9 * cos(dateTime.second * 6 * pi / 180 - pi / 2);
    final secondHandY =
        center.dy + radius * 0.9 * sin(dateTime.second * 6 * pi / 180 - pi / 2);
    canvas.drawLine(center, Offset(secondHandX, secondHandY), secondHandPaint);

    // Draw center point
    final centerPointPaint = Paint()..color = Colors.black;
    canvas.drawCircle(center, 8, centerPointPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class DigitalClock extends StatefulWidget {
  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final second = dateTime.second;
    final period = hour >= 12 ? 'PM' : 'am';
    final formattedHour = hour % 12 == 0 ? 12 : hour % 12;
    return "${formattedHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')} $period";
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final dateTime = DateTime.now();
        final timeString = _formatTime(dateTime);
        final timeParts = timeString.split(' ');
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
                  color: Colors.white,
                ),
              ),
              const TextSpan(
                text: ':',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: minute,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const TextSpan(
                text: ':',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: second,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: ' $period',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
