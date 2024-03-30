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
    print("time mode option provider");
    print(timeModeOption);

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

  @override
  void initState() {
    super.initState();
    currentTime = DateTime.now();
    _updateTimePeriodically();
  }

  void _updateTimePeriodically() {
    if (mounted) {
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          currentTime = DateTime.now();
        });
        _updateTimePeriodically();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      widget.formatter.format(currentTime),
      style: TextStyle(fontSize: 20),
    );
  }
}
