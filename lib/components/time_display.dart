import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/time_mode_provider.dart';

class TimeDisplay extends ConsumerWidget {
  const TimeDisplay({super.key});

  

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Subscribe to the timeModeProvider
    final timeModeOption = ref.watch(timeModeProvider);

    // Decide the format based on the TimeModeOption
    final is24HourFormat = timeModeOption == TimeModeOption.military; // Assuming `military` is the 24-hour option
    final formatter = DateFormat(is24HourFormat ? 'HH:mm:ss' : 'hh:mm:ss a');

    // Pass a key to the _TimeDisplayContent to force it to rebuild whenever the format changes
    return _TimeDisplayContent(
      key: ValueKey(is24HourFormat),
      formatter: formatter,
    );
  }
}

class _TimeDisplayContent extends StatefulWidget {
  final DateFormat formatter;

  const _TimeDisplayContent({Key? key, required this.formatter}) : super(key: key);

  @override
  _TimeDisplayContentState createState() => _TimeDisplayContentState();
}

class _TimeDisplayContentState extends State<_TimeDisplayContent> {
  late DateTime currentTime;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    currentTime = DateTime.now();
    _updateTimePeriodically();
  }

  @override
  void dispose() {
    _isActive = false;
    super.dispose();
  }

  void _updateTimePeriodically() {
    if (_isActive) {
      Future.delayed(Duration(seconds: 1), () {
        if (_isActive) {
          setState(() {
            currentTime = DateTime.now();
          });
          _updateTimePeriodically();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.formatter.format(currentTime),
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          DateFormat('EEEE, MMMM d, y').format(currentTime),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
