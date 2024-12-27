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

    // Updated clock face with contrasting colors
    final facePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          theme.colorScheme.surface,          // Inner color
          theme.colorScheme.surface.withOpacity(0.8), // Outer color
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, facePaint);

    // Updated border with secondary color
    final borderPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          theme.colorScheme.secondary,  // Changed from primary to secondary
          theme.colorScheme.secondary.withOpacity(0.7),  // Changed from primary to secondary
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    // Darker border outline using secondary color
    final borderOutlinePaint = Paint()
      ..color = theme.colorScheme.secondary.withOpacity(0.8)  // Changed from primary to secondary
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
          color: theme.colorScheme.onSurface,  // Use onSurface for better contrast
          fontSize: 24,
          fontWeight: FontWeight.w600,
          fontFamily: 'Playfair Display',
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
          color: theme.colorScheme.onSurface.withOpacity(0.8),  // Use onSurface with opacity
          fontSize: 10,
          fontWeight: FontWeight.w400,
          fontFamily: 'Arial',
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
      ..color = theme.colorScheme.onSurface.withOpacity(0.6)  // Use onSurface with opacity
      ..strokeWidth = 1.5;
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

    // Define a function to draw text with background
    void drawTextWithBackground(String text, Offset position, {bool isDate = false}) {
      TextStyle style;
      if (isDate) {
        style = TextStyle(
          color: theme.colorScheme.onBackground,  // Changed from primary
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: 'Playfair Display',
          letterSpacing: 0.5,
        );
      } else {
        style = TextStyle(
          color: theme.colorScheme.onBackground,  // Changed from primary.withOpacity(0.9)
          fontSize: 12,
          fontWeight: FontWeight.w400,
          fontFamily: 'Arial',
        );
      }
      
      textPainter.text = TextSpan(text: text, style: style);
      textPainter.layout();

      // Draw background with slight opacity for better contrast
      final backgroundPaint = Paint()
        ..color = theme.scaffoldBackgroundColor.withOpacity(0.8);
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

    // Update the date indicator to include day abbreviation
    drawTextWithBackground(
      '${_getDayAbbreviation(dateTime.weekday)} ${dateTime.day}',
      Offset(center.dx + radius * 0.4, center.dy),
      isDate: true, // Special styling for the date
    );

    // Move the ChronoLog brand name drawing before the hands
    final brandTextPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    brandTextPainter.text = TextSpan(
      text: 'ChronoLog',
      style: TextStyle(
        color: theme.colorScheme.tertiary.withOpacity(0.9), // Slightly transparent
        fontSize: 16, // Slightly smaller
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
        fontFamily: 'Playfair Display',
        letterSpacing: 2.0,
        shadows: [
          Shadow(
            color: theme.colorScheme.onSurface.withOpacity(0.2),
            offset: Offset(0, 1),
            blurRadius: 1,
          ),
        ],
      ),
    );
    
    brandTextPainter.layout();
    brandTextPainter.paint(
      canvas,
      Offset(
        center.dx - brandTextPainter.width / 2,
        center.dy - radius * 0.35, // Changed from 0.15 to 0.3 to move it up closer to 12 o'clock
      ),
    );

    // Calculate hour hand position first
    final hourAngle = (dateTime.hour % 12 + dateTime.minute / 60) * 30 * pi / 180 - pi / 2;
    final hourHandX = center.dx + radius * 0.5 * cos(hourAngle);
    final hourHandY = center.dy + radius * 0.5 * sin(hourAngle);

    // Hour Hand (Sword-shaped with blunter tip)
    final hourHandPath = Path();
    final hourHandLength = radius * 0.5;
    final hourHandWidth = 14.0;
    final hourHandTipWidth = 6.0;  // New: width at the tip
    
    hourHandPath.moveTo(
      center.dx + cos(hourAngle - pi/2) * (hourHandWidth/2),
      center.dy + sin(hourAngle - pi/2) * (hourHandWidth/2)
    );
    hourHandPath.lineTo(
      center.dx + cos(hourAngle) * hourHandLength + cos(hourAngle - pi/2) * (hourHandTipWidth/2),
      center.dy + sin(hourAngle) * hourHandLength + sin(hourAngle - pi/2) * (hourHandTipWidth/2)
    );
    hourHandPath.lineTo(
      center.dx + cos(hourAngle) * hourHandLength + cos(hourAngle + pi/2) * (hourHandTipWidth/2),
      center.dy + sin(hourAngle) * hourHandLength + sin(hourAngle + pi/2) * (hourHandTipWidth/2)
    );
    hourHandPath.lineTo(
      center.dx + cos(hourAngle + pi/2) * (hourHandWidth/2),
      center.dy + sin(hourAngle + pi/2) * (hourHandWidth/2)
    );
    hourHandPath.close();

    final hourHandPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.grey[400]!,
          Colors.grey[600]!,
        ],
      ).createShader(Rect.fromCenter(
        center: center,
        width: hourHandLength * 2,
        height: hourHandWidth,
      ));

    canvas.drawPath(hourHandPath, hourHandPaint);

    // Calculate minute hand position first
    final minuteAngle = (dateTime.minute + dateTime.second / 60) * 6 * pi / 180 - pi / 2;
    final minuteHandX = center.dx + radius * 0.7 * cos(minuteAngle);
    final minuteHandY = center.dy + radius * 0.7 * sin(minuteAngle);

    // Minute Hand (Thinner sword shape with blunter tip)
    final minuteHandPath = Path();
    final minuteHandLength = radius * 0.7;
    final minuteHandWidth = 12.0;
    final minuteHandTipWidth = 4.0;  // New: width at the tip

    minuteHandPath.moveTo(
      center.dx + cos(minuteAngle - pi/2) * (minuteHandWidth/2),
      center.dy + sin(minuteAngle - pi/2) * (minuteHandWidth/2)
    );
    minuteHandPath.lineTo(
      center.dx + cos(minuteAngle) * minuteHandLength + cos(minuteAngle - pi/2) * (minuteHandTipWidth/2),
      center.dy + sin(minuteAngle) * minuteHandLength + sin(minuteAngle - pi/2) * (minuteHandTipWidth/2)
    );
    minuteHandPath.lineTo(
      center.dx + cos(minuteAngle) * minuteHandLength + cos(minuteAngle + pi/2) * (minuteHandTipWidth/2),
      center.dy + sin(minuteAngle) * minuteHandLength + sin(minuteAngle + pi/2) * (minuteHandTipWidth/2)
    );
    minuteHandPath.lineTo(
      center.dx + cos(minuteAngle + pi/2) * (minuteHandWidth/2),
      center.dy + sin(minuteAngle + pi/2) * (minuteHandWidth/2)
    );
    minuteHandPath.close();

    final minuteHandPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.grey[400]!,
          Colors.grey[600]!,
        ],
      ).createShader(Rect.fromCenter(
        center: center,
        width: minuteHandLength * 2,
        height: minuteHandWidth,
      ));

    canvas.drawPath(minuteHandPath, minuteHandPaint);

    // Calculate second hand position first
    final secondFraction = dateTime.millisecond / 1000 + dateTime.second;
    final secondAngle = secondFraction * 6 * pi / 180 - pi / 2;
    final secondHandX = center.dx + radius * 0.9 * cos(secondAngle);
    final secondHandY = center.dy + radius * 0.9 * sin(secondAngle);

    // Second Hand (with blunter tip)
    final secondHandPath = Path();
    final secondHandLength = radius * 0.9;
    final secondHandWidth = 5.0;
    final secondHandTipWidth = 2.0;  // New: width at the tip

    secondHandPath.moveTo(
      center.dx + cos(secondAngle - pi/2) * (secondHandWidth/2),
      center.dy + sin(secondAngle - pi/2) * (secondHandWidth/2)
    );
    secondHandPath.lineTo(
      center.dx + cos(secondAngle) * secondHandLength + cos(secondAngle - pi/2) * (secondHandTipWidth/2),
      center.dy + sin(secondAngle) * secondHandLength + sin(secondAngle - pi/2) * (secondHandTipWidth/2)
    );
    secondHandPath.lineTo(
      center.dx + cos(secondAngle) * secondHandLength + cos(secondAngle + pi/2) * (secondHandTipWidth/2),
      center.dy + sin(secondAngle) * secondHandLength + sin(secondAngle + pi/2) * (secondHandTipWidth/2)
    );
    secondHandPath.lineTo(
      center.dx + cos(secondAngle + pi/2) * (secondHandWidth/2),
      center.dy + sin(secondAngle + pi/2) * (secondHandWidth/2)
    );
    secondHandPath.close();

    // Second hand counterweight
    final counterweightPath = Path();
    final counterweightLength = radius * 0.2;
    final counterweightWidth = 8.0;

    counterweightPath.moveTo(
      center.dx + cos(secondAngle + pi - pi/2) * (counterweightWidth/2),
      center.dy + sin(secondAngle + pi - pi/2) * (counterweightWidth/2)
    );
    counterweightPath.lineTo(
      center.dx + cos(secondAngle + pi) * counterweightLength,
      center.dy + sin(secondAngle + pi) * counterweightLength
    );
    counterweightPath.lineTo(
      center.dx + cos(secondAngle + pi + pi/2) * (counterweightWidth/2),
      center.dy + sin(secondAngle + pi + pi/2) * (counterweightWidth/2)
    );
    counterweightPath.close();

    final secondHandPaint = Paint()
      ..color = Colors.grey[500]!;

    canvas.drawPath(secondHandPath, secondHandPaint);
    canvas.drawPath(counterweightPath, secondHandPaint);

    // Draw center cap
    final centerCapPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.grey[300]!,
          Colors.grey[600]!,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 8));
    canvas.drawCircle(center, 8, centerCapPaint);
  }

  String _getMonthAbbreviation(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  // Add new helper method for day abbreviation
  String _getDayAbbreviation(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  @override
  
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

