import 'package:flutter/material.dart';
import 'dart:math';

class AnalogClockFace extends StatelessWidget {
  final DateTime time;
  final double size;

  const AnalogClockFace({
    Key? key,
    required this.time,
    this.size = 24.0,  // Default small size for icon usage
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: ClockFacePainter(time, Theme.of(context)),
      ),
    );
  }
}

class ClockFacePainter extends CustomPainter {
  final DateTime dateTime;
  final ThemeData theme;

  ClockFacePainter(this.dateTime, this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);

    // Clean, minimal clock face
    final facePaint = Paint()
      ..color = theme.colorScheme.surface
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, facePaint);

    // Subtle border
    final borderPaint = Paint()
      ..color = theme.colorScheme.onSurface.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.02;
    canvas.drawCircle(center, radius, borderPaint);

    // Minimal hour markers
    for (int i = 1; i <= 12; i++) {
      final angle = i * 30 * pi / 180;
      final markerStart = Offset(
        center.dx + radius * 0.85 * cos(angle - pi / 2),
        center.dy + radius * 0.85 * sin(angle - pi / 2),
      );
      final markerEnd = Offset(
        center.dx + radius * 0.95 * cos(angle - pi / 2),
        center.dy + radius * 0.95 * sin(angle - pi / 2),
      );
      
      canvas.drawLine(
        markerStart,
        markerEnd,
        Paint()
          ..color = theme.colorScheme.onSurface
          ..strokeWidth = radius * 0.04
          ..strokeCap = StrokeCap.round
      );
    }

    // Hour hand
    _drawHand(
      canvas,
      center,
      radius * 0.5, // Length
      (dateTime.hour % 12 + dateTime.minute / 60) * 30 * pi / 180 - pi / 2,
      radius * 0.08, // Width
      theme.colorScheme.onSurface,
    );

    // Minute hand
    _drawHand(
      canvas,
      center,
      radius * 0.7, // Length
      (dateTime.minute + dateTime.second / 60) * 6 * pi / 180 - pi / 2,
      radius * 0.06, // Width
      theme.colorScheme.onSurface,
    );

    // Second hand
    _drawHand(
      canvas,
      center,
      radius * 0.8, // Length
      dateTime.second * 6 * pi / 180 - pi / 2,
      radius * 0.02, // Width
      theme.colorScheme.primary, // Accent color for seconds
    );

    // Center dot
    canvas.drawCircle(
      center,
      radius * 0.08,
      Paint()..color = theme.colorScheme.primary,
    );
  }

  void _drawHand(Canvas canvas, Offset center, double length, double angle, double width, Color color) {
    final handPaint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = width;

    canvas.drawLine(
      center,
      Offset(
        center.dx + length * cos(angle),
        center.dy + length * sin(angle),
      ),
      handPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}