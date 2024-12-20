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

    // Update timer to tick every 100 milliseconds
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        // Convert offset from minutes to hours for the Duration
        final offsetMinutes = _getTimeZoneOffset();
        _currentTime = DateTime.now().toUtc().add(Duration(minutes: offsetMinutes));
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
    
    // Convert the offset string to a double first, then to minutes
    final double offsetHours = double.parse(selectedZone['offset']!);
    return (offsetHours * 60).round(); // Convert hours to minutes
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);  // Get the current theme
    
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
              painter: ClockPainter(_currentTime, theme),  // Pass the theme
            ),
          ),
        ],
      ),
    );
  }
}

class ClockPainter extends CustomPainter {
  final DateTime dateTime;
  final ThemeData theme;

  ClockPainter(this.dateTime, this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);

    // Draw clock face with a gradient for a luxury look
    final facePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          theme.colorScheme.tertiary,           // Inner color
          theme.colorScheme.tertiary.withOpacity(0.7), // Outer color
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, facePaint);

    // Updated border with metallic gradient like the hands
    final borderPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.grey[400]!,
          Colors.grey[600]!,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    // Add a subtle border outline
    final borderOutlinePaint = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    canvas.drawCircle(center, radius, borderOutlinePaint);
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
          color: theme.colorScheme.primary,     // Use theme primary color
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
          color: theme.colorScheme.primary.withOpacity(0.8),
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
      ..color = theme.colorScheme.primary.withOpacity(0.6)
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
          color: theme.colorScheme.primary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();

      // Draw background rectangle
      final backgroundPaint = Paint()
        ..color = theme.colorScheme.tertiary.withOpacity(0.9);
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

    // Calculate hour hand position first
    final hourAngle = (dateTime.hour % 12 + dateTime.minute / 60) * 30 * pi / 180 - pi / 2;
    final hourHandX = center.dx + radius * 0.5 * cos(hourAngle);
    final hourHandY = center.dy + radius * 0.5 * sin(hourAngle);

    // Then use the coordinates in the shader
    final hourHandPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.grey[400]!,
          Colors.grey[600]!,
        ],
      ).createShader(Rect.fromPoints(center, Offset(hourHandX, hourHandY)))
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    
    // Add a subtle border to the hour hand
    final hourHandBorderPaint = Paint()
      ..color = Colors.grey[800]!
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(center, Offset(hourHandX, hourHandY), hourHandBorderPaint);
    canvas.drawLine(center, Offset(hourHandX, hourHandY), hourHandPaint);

    // Calculate minute hand position first
    final minuteAngle = (dateTime.minute + dateTime.second / 60) * 6 * pi / 180 - pi / 2;
    final minuteHandX = center.dx + radius * 0.7 * cos(minuteAngle);
    final minuteHandY = center.dy + radius * 0.7 * sin(minuteAngle);

    // Then create the paint object using the calculated coordinates
    final minuteHandPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.grey[300]!,
          Colors.grey[500]!,
        ],
      ).createShader(Rect.fromPoints(center, Offset(minuteHandX, minuteHandY)))
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    
    final minuteHandBorderPaint = Paint()
      ..color = Colors.grey[700]!
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, Offset(minuteHandX, minuteHandY), minuteHandBorderPaint);
    canvas.drawLine(center, Offset(minuteHandX, minuteHandY), minuteHandPaint);

    // Calculate second hand position first
    final secondFraction = dateTime.millisecond / 1000 + dateTime.second;
    final secondAngle = secondFraction * 6 * pi / 180 - pi / 2;
    final secondHandX = center.dx + radius * 0.9 * cos(secondAngle);
    final secondHandY = center.dy + radius * 0.9 * sin(secondAngle);

    // Then create the paint object using the calculated coordinates
    final secondHandPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.grey[400]!,
          Colors.grey[600]!,
        ],
      ).createShader(Rect.fromPoints(center, Offset(secondHandX, secondHandY)))
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Add counterweight to second hand
    final counterweightPaint = Paint()
      ..color = Colors.grey[600]!
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    // Draw counterweight
    final counterweightX = center.dx + radius * 0.2 * cos(secondAngle + pi);
    final counterweightY = center.dy + radius * 0.2 * sin(secondAngle + pi);
    canvas.drawLine(center, Offset(counterweightX, counterweightY), counterweightPaint);
    canvas.drawLine(center, Offset(secondHandX, secondHandY), secondHandPaint);

    // Draw center cap
    final centerCapPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.grey[300]!,
          Colors.grey[600]!,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 8));
    canvas.drawCircle(center, 8, centerCapPaint);

    // Add Chronolog brand name below 12 o'clock
    final brandTextPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    brandTextPainter.text = TextSpan(
      text: 'ChronoLog',
      style: TextStyle(
        color: theme.colorScheme.primary.withOpacity(0.8),
        fontSize: 16,
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
        fontFamily: 'Playfair Display', // More classical serif font
        letterSpacing: 1.2, // Add some letter spacing for elegance
      ),
    );
    
    brandTextPainter.layout();
    brandTextPainter.paint(
      canvas,
      Offset(
        center.dx - brandTextPainter.width / 2,
        center.dy - radius * 0.35, // Moved up slightly from 0.3
      ),
    );
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

