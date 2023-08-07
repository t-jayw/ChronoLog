import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data_helpers.dart/timing_run_parser.dart';
import '../models/timepiece.dart';
import '../models/timing_measurement.dart';
import '../models/timing_run.dart';
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
    int allSecondsRun = 0;

    int mostRecentOffsetInSeconds = 0;

    TimingRun mostRecentRun = timingRuns.last;
    List<TimingMeasurement> mostRecentRunMeasurements =
        ref.watch(timingMeasurementsListProvider(mostRecentRun.id));
    mostRecentOffsetInSeconds = mostRecentRunMeasurements.first.user_input_time!
        .difference(mostRecentRunMeasurements.first.system_time)
        .inSeconds;

    timingRuns.forEach((run) {
      int totalDuration;
      double totalDurationDays;

      final timingMeasurements =
          ref.watch(timingMeasurementsListProvider(run.id));
      totalDuration = calculateTotalDuration(timingMeasurements);
      allSecondsRun = totalDuration;
      totalDurationDays = totalDuration / 60 / 60 / 24;

      allMeasurements += timingMeasurements.length;
      allRunsDuration += totalDuration;
      allDaysRun += totalDurationDays;
      allRunsDifferenceInSeconds += calculateTotalSecondsChange(timingMeasurements);
    });

    print('here');
    print(allRunsDifferenceInSeconds);
    print(allDaysRun);
    double secPerDay =
        allDaysRun != 0.0 ?
          allRunsDifferenceInSeconds / allDaysRun :
          0.0;

    if (timingRuns.isEmpty) {
      return StatsGrid(
        runs: 0,
        points: 0,
        duration: 0,
        totalSecondsChanged: 0,
        rateSecPerDay: 0,
      );
    }

    return StatsGrid(
      runs: timingRuns.length,
      points: allMeasurements,
      duration: allRunsDuration,
      totalSecondsChanged: mostRecentOffsetInSeconds,
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
          TextWithLabel(
              value:
                  '${formatDuration(Duration(seconds: totalSecondsChanged))}',
              label: 'Offset:',
              color: Theme.of(context).colorScheme.tertiary,
              labelSize: 14),
          Divider(),

          Text('All Runs', style: TextStyle(fontSize: 16)),
          TextWithLabel(
            value: '$rate',
            label: 'Sec/Day:',
            color: Theme.of(context).colorScheme.tertiary,
            labelSize: 20,
          ),

          TextWithLabel(
            value: '${formatDuration(Duration(seconds: duration))}',
            label: 'Duration:',
            color: Theme.of(context).colorScheme.tertiary,
          ),
          TextWithLabel(
            value: '$runs',
            label: 'Runs:',
            color: Theme.of(context).colorScheme.tertiary,
          ),

          TextWithLabel(
            value: '$points',
            label: 'Points:',
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
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: labelSize ?? 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
