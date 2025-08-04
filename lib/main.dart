import 'package:flutter/material.dart';
import 'core/locator/service_locator.dart';
import 'features/clock/widgets/clock_screen.dart';

/// Application entry point
void main() async {
  // Ensure Flutter bindings are initialized first
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services after bindings are ready
  await _initializeApp();

  runApp(const ClockApp());
}

/// Initialize application services and dependencies
Future<void> _initializeApp() async {
  final serviceLocator = ServiceLocator.instance;
  await serviceLocator.setupServices();
}

/// Root application widget following Single Responsibility Principle
class ClockApp extends StatelessWidget {
  const ClockApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Analog Wall Clock',
      debugShowCheckedModeBanner: false,
      home: ClockScreen(),
    );
  }
}





/// old code
/// 
/// 
// import 'dart:async';

// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
// import 'dart:math';

// void main() {
//   runApp(const MainApp());
// }

// class MainApp extends StatelessWidget {
//   const MainApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         backgroundColor: Colors.grey,
//         body: Center(
//           child: Clock(),
//         ),
//       ),
//     );
//   }
// }

// class Clock extends StatefulWidget {
//   @override
//   _ClockState createState() => _ClockState();
// }

// class _ClockState extends State<Clock>
//     with SingleTickerProviderStateMixin, WidgetsBindingObserver {
//   late AnimationController _controller;
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   final AudioCache _audioCache = AudioCache(prefix: 'assets/');
//   late Uri filePath;
//   Timer? _timer; // Make timer nullable
//   bool _isAppInForeground = true;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);

//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 1),
//     )..repeat();

//     SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
//       // Preload the audio file
//       filePath = await _audioCache.load('tick.mp3');
//     });

//     _startTicking();
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _controller.dispose();
//     _audioPlayer.dispose();
//     _timer?.cancel(); // Use null-aware operator
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);

//     switch (state) {
//       case AppLifecycleState.resumed:
//         // App is in foreground and active
//         _isAppInForeground = true;
//         _startTicking();
//         break;
//       case AppLifecycleState.paused:
//       case AppLifecycleState.inactive:
//       case AppLifecycleState.detached:
//         // App is in background, paused, or inactive
//         _isAppInForeground = false;
//         _stopTicking();
//         break;
//       case AppLifecycleState.hidden:
//         // App is hidden but still running
//         _isAppInForeground = false;
//         _stopTicking();
//         break;
//     }
//   }

//   void _startTicking() {
//     if (_isAppInForeground) {
//       _timer?.cancel(); // Use null-aware operator
//       _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//         if (_isAppInForeground) {
//           _playTickSound();
//         }
//       });
//     }
//   }

//   void _stopTicking() {
//     _timer?.cancel(); // Use null-aware operator
//   }

//   Future<void> _playTickSound() async {
//     try {
//       await _audioPlayer.stop(); // Ensure the player is stopped before playing
//       await _audioPlayer.play(DeviceFileSource(filePath.path),
//           mode: PlayerMode.lowLatency);
//     } catch (e) {
//       debugPrint('Error playing tick sound: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final clockSize = min(screenSize.width, screenSize.height) * 0.8;

//     return Stack(
//       children: [
//         Center(
//           child: AnimatedBuilder(
//             animation: _controller,
//             builder: (context, child) {
//               return CustomPaint(
//                 painter: ClockPainter(),
//                 size: Size(clockSize, clockSize),
//               );
//             },
//           ),
//         ),
//         Align(
//           alignment: Alignment.bottomCenter,
//           child: Padding(
//             padding: const EdgeInsets.only(bottom: 40),
//             child: DigitalClock(),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class ClockPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
//     final radius = min(size.width / 1.8, size.height);
//     final dateTime = DateTime.now();

//     // Draw outer white circle (clock background)
//     final backgroundPaint = Paint()
//       ..color = Colors.white
//       ..style = PaintingStyle.fill;
//     canvas.drawCircle(center, radius, backgroundPaint);

//     // Draw subtle shadow/border
//     final borderPaint = Paint()
//       ..color = Colors.grey.shade300
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2;
//     canvas.drawCircle(center, radius, borderPaint);

//     // Draw inner clock face (grey gradient)
//     final innerRadius = radius * 0.7;
//     final facePaint = Paint()
//       ..shader = RadialGradient(
//         colors: [Colors.white, Colors.grey.shade300],
//       ).createShader(Rect.fromCircle(center: center, radius: innerRadius));
//     canvas.drawCircle(center, innerRadius, facePaint);

//     // Draw hour markers and numbers
//     _drawMarkers(canvas, center, radius);

//     // Draw clock hands
//     _drawHands(canvas, center, innerRadius, dateTime);

//     // Draw center point
//     final centerPointPaint = Paint()..color = Colors.black;
//     canvas.drawCircle(center, 8, centerPointPaint);
//   }

//   void _drawMarkers(Canvas canvas, Offset center, double radius) {
//     final markerRadius = radius * 0.92; // Distance from center to markers

//     // Paint for hour markers (thick orange lines)
//     final hourMarkerPaint = Paint()
//       ..color = Colors.orange
//       ..strokeWidth = 1.5
//       ..strokeCap = StrokeCap.round;

//     // Paint for minute markers (small orange dots)
//     final minuteMarkerPaint = Paint()
//       ..color = Colors.orange
//       ..style = PaintingStyle.fill;

//     // Paint for hour numbers
//     final textPainter = TextPainter(
//       textAlign: TextAlign.center,
//       textDirection: TextDirection.ltr,
//     );

//     for (int i = 0; i < 60; i++) {
//       final angle = (i * 6 - 90) * pi / 180; // Start from 12 o'clock
//       final isHourMarker = i % 5 == 0;

//       if (isHourMarker) {
//         // Draw hour markers (lines)
//         final outerPoint = Offset(
//           center.dx + markerRadius * cos(angle),
//           center.dy + markerRadius * sin(angle),
//         );
//         final innerPoint = Offset(
//           center.dx + (markerRadius - 8) * cos(angle),
//           center.dy + (markerRadius - 8) * sin(angle),
//         );
//         canvas.drawLine(outerPoint, innerPoint, hourMarkerPaint);

//         // Draw hour numbers
//         if (i > 0) {
//           // Skip 0, show 12 instead
//           final numberRadius = markerRadius - 25;
//           final numberX = center.dx + numberRadius * cos(angle);
//           final numberY = center.dy + numberRadius * sin(angle);

//           textPainter.text = TextSpan(
//             text: i == 0 ? '12' : '$i',
//             style: TextStyle(
//               color: Colors.black87,
//               fontSize: radius * 0.05,
//               fontWeight: FontWeight.w600,
//             ),
//           );
//           textPainter.layout();

//           // Center the text
//           final textOffset = Offset(
//             numberX - textPainter.width / 2,
//             numberY - textPainter.height / 2,
//           );
//           textPainter.paint(canvas, textOffset);
//         }
//       } else {
//         // Draw minute markers (small dots)
//         final dotCenter = Offset(
//           center.dx + markerRadius * cos(angle),
//           center.dy + markerRadius * sin(angle),
//         );
//         canvas.drawCircle(dotCenter, 2, minuteMarkerPaint);
//       }
//     }

//     // Draw "12" at the top
//     final numberRadius = markerRadius - 25;
//     final numberX = center.dx;
//     final numberY = center.dy - numberRadius;

//     textPainter.text = TextSpan(
//       text: '12',
//       style: TextStyle(
//         color: Colors.black87,
//         fontSize: radius * 0.08,
//         fontWeight: FontWeight.w600,
//       ),
//     );
//     textPainter.layout();

//     final textOffset = Offset(
//       numberX - textPainter.width / 2,
//       numberY - textPainter.height / 2,
//     );
//     textPainter.paint(canvas, textOffset);
//   }

//   void _drawHands(
//       Canvas canvas, Offset center, double radius, DateTime dateTime) {
//     // Draw hour hand
//     final hourHandPaint = Paint()
//       ..color = Colors.black
//       ..strokeWidth = 8
//       ..strokeCap = StrokeCap.round;
//     final hourAngle =
//         (dateTime.hour % 12 * 30 + dateTime.minute * 0.5) * pi / 180 - pi / 2;
//     final hourHandEnd = Offset(
//       center.dx + radius * 0.5 * cos(hourAngle),
//       center.dy + radius * 0.5 * sin(hourAngle),
//     );
//     canvas.drawLine(center, hourHandEnd, hourHandPaint);

//     // Draw minute hand
//     final minuteHandPaint = Paint()
//       ..color = Colors.black
//       ..strokeWidth = 4
//       ..strokeCap = StrokeCap.round;
//     final minuteAngle = dateTime.minute * 6 * pi / 180 - pi / 2;
//     final minuteHandEnd = Offset(
//       center.dx + radius * 0.7 * cos(minuteAngle),
//       center.dy + radius * 0.7 * sin(minuteAngle),
//     );
//     canvas.drawLine(center, minuteHandEnd, minuteHandPaint);

//     // Draw second hand
//     final secondHandPaint = Paint()
//       ..color = Colors.red
//       ..strokeWidth = 2
//       ..strokeCap = StrokeCap.round;
//     final secondAngle = dateTime.second * 6 * pi / 180 - pi / 2;
//     final secondHandEnd = Offset(
//       center.dx + radius * 0.9 * cos(secondAngle),
//       center.dy + radius * 0.9 * sin(secondAngle),
//     );
//     canvas.drawLine(center, secondHandEnd, secondHandPaint);
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return true;
//   }
// }

// class DigitalClock extends StatefulWidget {
//   @override
//   _DigitalClockState createState() => _DigitalClockState();
// }

// class _DigitalClockState extends State<DigitalClock>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 1),
//     )..repeat();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   String _formatTime(DateTime dateTime) {
//     final hour = dateTime.hour;
//     final minute = dateTime.minute;
//     final second = dateTime.second;
//     final period = hour >= 12 ? 'PM' : 'am';
//     final formattedHour = hour % 12 == 0 ? 12 : hour % 12;
//     return "${formattedHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')} $period";
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (context, child) {
//         final dateTime = DateTime.now();
//         final timeString = _formatTime(dateTime);
//         final timeParts = timeString.split(' ');
//         final time = timeParts[0];
//         final period = timeParts[1];

//         final timeComponents = time.split(':');
//         final hour = timeComponents[0];
//         final minute = timeComponents[1];
//         final second = timeComponents[2];

//         return RichText(
//           text: TextSpan(
//             children: [
//               TextSpan(
//                 text: hour,
//                 style: const TextStyle(
//                   fontSize: 50,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               const TextSpan(
//                 text: ':',
//                 style: TextStyle(
//                   fontSize: 40,
//                   fontWeight: FontWeight.normal,
//                   color: Colors.white,
//                 ),
//               ),
//               TextSpan(
//                 text: minute,
//                 style: const TextStyle(
//                   fontSize: 40,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white,
//                 ),
//               ),
//               const TextSpan(
//                 text: ':',
//                 style: TextStyle(
//                   fontSize: 30,
//                   fontWeight: FontWeight.normal,
//                   color: Colors.white,
//                 ),
//               ),
//               TextSpan(
//                 text: second,
//                 style: const TextStyle(
//                   fontSize: 30,
//                   fontWeight: FontWeight.normal,
//                   color: Colors.white,
//                 ),
//               ),
//               TextSpan(
//                 text: ' $period',
//                 style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.normal,
//                   color: Colors.white,
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
