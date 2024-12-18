import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class AnalogClock extends StatefulWidget {
  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> {
  Timer? _timer;
  DateTime _currentTime = DateTime.now();
  String _selectedTimeZone = 'UTC';

  final List<Map<String, String>> _timeZones = [
    {'city': 'Los Angeles', 'abbreviation': 'PST', 'offset': '-8'},
    {'city': 'Denver', 'abbreviation': 'MST', 'offset': '-7'},
    {'city': 'Chicago', 'abbreviation': 'CST', 'offset': '-6'},
    {'city': 'New York', 'abbreviation': 'EST', 'offset': '-5'},
    {'city': 'Rio de Janeiro', 'abbreviation': 'BRT', 'offset': '-3'},
    {'city': 'London', 'abbreviation': 'UTC', 'offset': '0'},
    {'city': 'Paris', 'abbreviation': 'CET', 'offset': '1'},
    {'city': 'Moscow', 'abbreviation': 'MSK', 'offset': '3'},
    {'city': 'Dubai', 'abbreviation': 'GST', 'offset': '4'},
    {'city': 'Karachi', 'abbreviation': 'PKT', 'offset': '5'},
    {'city': 'Dhaka', 'abbreviation': 'BST', 'offset': '6'},
    {'city': 'Bangkok', 'abbreviation': 'ICT', 'offset': '7'},
    {'city': 'Beijing', 'abbreviation': 'CST', 'offset': '8'},
    {'city': 'Tokyo', 'abbreviation': 'JST', 'offset': '9'},
    {'city': 'Sydney', 'abbreviation': 'AEST', 'offset': '10'},
    {'city': 'Noumea', 'abbreviation': 'NCT', 'offset': '11'},
    {'city': 'Auckland', 'abbreviation': 'NZST', 'offset': '12'},
    {'city': 'Honolulu', 'abbreviation': 'HST', 'offset': '-10'},
    {'city': 'Anchorage', 'abbreviation': 'AKST', 'offset': '-9'},
    {'city': 'Mexico City', 'abbreviation': 'CST', 'offset': '-6'},
    {'city': 'Caracas', 'abbreviation': 'VET', 'offset': '-4'},
    {'city': 'Santiago', 'abbreviation': 'CLT', 'offset': '-3'},
    {'city': 'Buenos Aires', 'abbreviation': 'ART', 'offset': '-3'},
    {'city': 'Azores', 'abbreviation': 'AZOT', 'offset': '-1'},
    // Additional cities
    {'city': 'Cairo', 'abbreviation': 'EET', 'offset': '2'},
    {'city': 'Johannesburg', 'abbreviation': 'SAST', 'offset': '2'},
    {'city': 'Istanbul', 'abbreviation': 'TRT', 'offset': '3'},
    {'city': 'Mumbai', 'abbreviation': 'IST', 'offset': '5.5'},
    {'city': 'Singapore', 'abbreviation': 'SGT', 'offset': '8'},
    {'city': 'Seoul', 'abbreviation': 'KST', 'offset': '9'},
    {'city': 'Melbourne', 'abbreviation': 'AEDT', 'offset': '11'},
    {'city': 'Fiji', 'abbreviation': 'FJT', 'offset': '12'},
    {'city': 'Tonga', 'abbreviation': 'TOT', 'offset': '13'},
  ];

  int _initialTimeZoneIndex = 0;

  @override
  void initState() {
    super.initState();
    
    // Sort by offset from UTC
    _timeZones.sort((a, b) => double.parse(a['offset']!).compareTo(double.parse(b['offset']!)));

    // Set initial timezone based on user's current timezone
    _selectedTimeZone = _getUserTimeZone();

    // Find the index of the user's timezone
    _initialTimeZoneIndex = _timeZones.indexWhere((zone) => zone['abbreviation'] == _selectedTimeZone);

    // Update timer to tick every 250 milliseconds
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        _currentTime = DateTime.now().toUtc().add(Duration(hours: _getTimeZoneOffset()));
      });
    });
  }

  String _getUserTimeZone() {
    // Use the system's current timezone offset to find the matching timezone
    final currentOffset = DateTime.now().timeZoneOffset.inHours;
    final matchingZone = _timeZones.firstWhere(
      (zone) => int.parse(zone['offset']!) == currentOffset,
      orElse: () => {'abbreviation': 'UTC'}, // Default to UTC if no match is found
    );
    return matchingZone['abbreviation']!;
  }

  int _getTimeZoneOffset() {
    final selectedZone = _timeZones.firstWhere(
      (zone) => zone['abbreviation'] == _selectedTimeZone,
      orElse: () => {'offset': '0'},
    );
    return int.parse(selectedZone['offset']!);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
      child: Column(
        children: [
          Container(
            height: 150,
            child: CupertinoPicker(
              itemExtent: 40.0,
              onSelectedItemChanged: (int index) {
                setState(() {
                  _selectedTimeZone = _timeZones[index]['abbreviation']!;
                });
              },
              scrollController: FixedExtentScrollController(initialItem: _initialTimeZoneIndex),
              children: _timeZones.map((timeZone) {
                return Center(
                  child: Text(
                    '${timeZone['city']} (${timeZone['abbreviation']}, UTC${timeZone['offset']})',
                    style: TextStyle(fontSize: 18.0),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 40),
          Container(
            width: 350,
            height: 350,
            child: CustomPaint(
              painter: ClockPainter(_currentTime),
            ),
          ),
        ],
      ),
    );
  }
}

class ClockPainter extends CustomPainter {
  final DateTime dateTime;

  ClockPainter(this.dateTime);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);

    // Draw clock face with a gradient for a luxury look
    final facePaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.black, Colors.grey[800]!],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, facePaint);

    // Draw clock border with a metallic look
    final borderPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.grey[700]!, Colors.grey[500]!],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8; // Thicker border
    canvas.drawCircle(center, radius, borderPaint);

    // Draw Arabic numeral indices for hours with a more distinct style
    final hourTextPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    for (int i = 1; i <= 12; i++) {
      final angle = i * 30 * pi / 180;
      final textOffset = Offset(
        center.dx + radius * 0.75 * cos(angle - pi / 2),
        center.dy + radius * 0.75 * sin(angle - pi / 2),
      );
      hourTextPainter.text = TextSpan(
        text: '$i',
        style: TextStyle(
          color: Colors.white, // White text for better contrast
          fontSize: 20, // Larger font size
          fontWeight: FontWeight.bold,
        ),
      );
      hourTextPainter.layout();
      hourTextPainter.paint(
        canvas,
        textOffset - Offset(hourTextPainter.width / 2, hourTextPainter.height / 2),
      );
    }

    // Draw minute track values with the same color as hour indicators
    final minuteTextPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    for (int i = 1; i <= 12; i++) {
      final angle = i * 30 * pi / 180;
      final textOffset = Offset(
        center.dx + radius * 0.6 * cos(angle - pi / 2),
        center.dy + radius * 0.6 * sin(angle - pi / 2),
      );
      minuteTextPainter.text = TextSpan(
        text: '${i * 5}',
        style: TextStyle(
          color: Colors.white, // Same color as hour indicators
          fontSize: 12,
        ),
      );
      minuteTextPainter.layout();
      minuteTextPainter.paint(
        canvas,
        textOffset - Offset(minuteTextPainter.width / 2, minuteTextPainter.height / 2),
      );
    }

    // Draw minute ticks with a smaller size
    final tickPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5; // Reduced stroke width for smaller ticks
    for (int i = 0; i < 60; i++) {
      final angle = i * 6 * pi / 180;
      final tickStart = Offset(
        center.dx + radius * 0.88 * cos(angle), // Adjusted for smaller ticks
        center.dy + radius * 0.88 * sin(angle),
      );
      final tickEnd = Offset(
        center.dx + radius * 0.92 * cos(angle), // Adjusted for smaller ticks
        center.dy + radius * 0.92 * sin(angle),
      );
      canvas.drawLine(tickStart, tickEnd, tickPaint);
    }

    // Draw month, year, and date indicators interior to minute indicators
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    // Define a function to draw text with a background
    void drawTextWithBackground(String text, Offset position) {
      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();

      // Draw background rectangle
      final backgroundPaint = Paint()..color = Colors.black.withOpacity(0.7);
      final backgroundRect = Rect.fromCenter(
        center: position,
        width: textPainter.width + 10,
        height: textPainter.height + 5,
      );
      canvas.drawRect(backgroundRect, backgroundPaint);

      // Draw text
      textPainter.paint(
        canvas,
        position - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    // Month abbreviation at 9 o'clock
    drawTextWithBackground(
      _getMonthAbbreviation(dateTime.month),
      Offset(center.dx - radius * 0.4, center.dy),
    );

    // Year at 6 o'clock
    drawTextWithBackground(
      '${dateTime.year}',
      Offset(center.dx, center.dy + radius * 0.4),
    );

    // Date at 3 o'clock
    drawTextWithBackground(
      '${dateTime.day}',
      Offset(center.dx + radius * 0.4, center.dy),
    );

    // Draw hour hand with a modern sports watch style
    final hourHandPaint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    final hourAngle = (dateTime.hour % 12 + dateTime.minute / 60) * 30 * pi / 180 - pi / 2;
    final hourHandX = center.dx + radius * 0.5 * cos(hourAngle);
    final hourHandY = center.dy + radius * 0.5 * sin(hourAngle);
    canvas.drawLine(center, Offset(hourHandX, hourHandY), hourHandPaint);

    // Draw minute hand with a modern sports watch style
    final minuteHandPaint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    final minuteAngle = (dateTime.minute + dateTime.second / 60) * 6 * pi / 180 - pi / 2;
    final minuteHandX = center.dx + radius * 0.7 * cos(minuteAngle);
    final minuteHandY = center.dy + radius * 0.7 * sin(minuteAngle);
    canvas.drawLine(center, Offset(minuteHandX, minuteHandY), minuteHandPaint);

    // Draw second hand with a modern sports watch style
    final secondHandPaint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Calculate the angle for the second hand with 4 ticks per second
    final secondFraction = dateTime.millisecond / 1000 + dateTime.second;
    final secondAngle = secondFraction * 6 * pi / 180 - pi / 2;
    final secondHandX = center.dx + radius * 0.9 * cos(secondAngle);
    final secondHandY = center.dy + radius * 0.9 * sin(secondAngle);
    canvas.drawLine(center, Offset(secondHandX, secondHandY), secondHandPaint);
  }

  String _getMonthAbbreviation(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

