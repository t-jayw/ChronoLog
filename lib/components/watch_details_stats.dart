import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data_helpers.dart/timing_run_parser.dart';
import '../models/timepiece.dart';
import '../providers/timing_measurements_list_provider.dart';
import '../providers/timing_run_provider.dart';

String formatDuration(Duration d) {
  if (d.inDays > 365) {
    return '${d.inDays ~/ 365} year${d.inDays ~/ 365 != 1 ? 's' : ''}';
  } else if (d.inDays > 30) {
    return '${d.inDays ~/ 30} month${d.inDays ~/ 30 != 1 ? 's' : ''}';
  } else if (d.inDays > 7) {
    return '${d.inDays ~/ 7} week${d.inDays ~/ 7 != 1 ? 's' : ''}';
  } else if (d.inDays > 0) {
    return '${d.inDays} day${d.inDays != 1 ? 's' : ''}';
  } else if (d.inHours > 0) {
    return '${d.inHours} hour${d.inHours != 1 ? 's' : ''}';
  } else if (d.inMinutes > 0) {
    return '${d.inMinutes} minute${d.inMinutes != 1 ? 's' : ''}';
  } else {
    return '${d.inSeconds} second${d.inSeconds != 1 ? 's' : ''}';
  }
}

class WatchDetailStats extends ConsumerWidget {
  final Timepiece timepiece;
  WatchDetailStats({Key? key, required this.timepiece}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timingRuns = ref.watch(timingRunProvider(timepiece.id));

    int allMeasurements = 0;
    int allRunsDuration = 0;
    int allRunsDifferenceInSeconds = 0;
    double allDaysRun = 0;

    timingRuns.forEach((run) {
      int totalDuration;
      double totalDurationDays;
      int totalSecondsChanged;

      final timingMeasurements =
          ref.watch(timingMeasurementsListProvider(run.id));
      totalDuration = calculateTotalDuration(timingMeasurements);
      totalDurationDays = totalDuration / 60 / 60 / 24;

      totalSecondsChanged = calculateTotalSecondsChange(timingMeasurements);

      allMeasurements += timingMeasurements.length;
      allRunsDuration += totalDuration;
      allDaysRun += totalDurationDays;
      allRunsDifferenceInSeconds += totalSecondsChanged;
    });

    double secPerDay =
        allDaysRun != 0.0 ? allRunsDifferenceInSeconds / allDaysRun : 0.0;
        
    return StatsGrid(
      runs: timingRuns.length,
      points: allMeasurements,
      duration: allRunsDuration,
      totalSecondsChanged: allRunsDifferenceInSeconds,
      rateSecPerDay: secPerDay,
    );
  }
}

class StatsGrid extends StatelessWidget {
  final int runs;
  final int points;
  final int duration;
  final int totalSecondsChanged;
  final double rateSecPerDay;

  StatsGrid(
      {Key? key,
      required this.runs,
      required this.points,
      required this.duration,
      required this.totalSecondsChanged,
      required this.rateSecPerDay})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String rate = rateSecPerDay.toStringAsFixed(1);

    return Container(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   'All Measurements',
          //   style: TextStyle(
          //     fontSize: 18,
          //     fontWeight: FontWeight.bold,
          //     color: Theme.of(context).colorScheme.secondary,
          //   ),
          // ),

          Text('All Runs:', style: TextStyle(fontSize: 14)),
          TextWithLabel(
            value: '$rate',
            label: 'Sec/Day',
            color: Theme.of(context).colorScheme.tertiary,
            labelSize: 22,
          ),
          TextWithLabel(
            value: '${formatDuration(Duration(seconds: totalSecondsChanged))}', 
            label: 'Offset',
            color: Theme.of(context).colorScheme.tertiary,
          ),
          TextWithLabel(
            value: '${formatDuration(Duration(seconds: duration))}',
            label: 'Duration',
            color: Theme.of(context).colorScheme.tertiary,
          ),
          TextWithLabel(
            value: '$runs',
            label: 'Runs',
            color: Theme.of(context).colorScheme.tertiary,
          ),

          TextWithLabel(
            value: '$points',
            label: 'Points',
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ],
      ),
    );
  }
}

class TextWithLabel extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final double? labelSize;

  TextWithLabel({
    Key? key,
    required this.value,
    required this.label,
    required this.color,
    this.labelSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.inverseSurface,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: labelSize ?? 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
