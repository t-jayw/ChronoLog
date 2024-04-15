import 'package:chronolog/components/share_content/share_content_stats.dart';
import 'package:chronolog/data_helpers.dart/format_duration.dart';
import 'package:chronolog/data_helpers.dart/timepiece_aggregate_stats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data_helpers.dart/timing_run_parser.dart';
import '../models/timepiece.dart';
import '../models/timing_measurement.dart';
import '../models/timing_run.dart';
import '../providers/timing_measurements_list_provider.dart';
import '../providers/timing_run_provider.dart';

class WatchDetailStats extends ConsumerWidget {
  final Timepiece timepiece;
  WatchDetailStats({Key? key, required this.timepiece}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timingRuns = ref.watch(timingRunProvider(timepiece.id));

    TimingRun? mostRecentRun = timingRuns.first;

    List<TimingMeasurement> mostRecentRunMeasurements =
        ref.watch(timingMeasurementsListProvider(mostRecentRun.id));

    final TimingRunStatistics timingRunStats =
        TimingRunStatistics(mostRecentRunMeasurements);

    final TimepieceAggregateStats timepieceStats =
        TimepieceAggregateStats(timepiece, ref);

    if (timingRuns.isEmpty) {
      return StatsGrid(
        runs: 0,
        points: 0,
        duration: 0,
        offset: '--',
        rateSecPerDay: 0,
      );
    }

    return StatsGrid(
      runs: timingRuns.length,
      points: timepieceStats.totalMeasurements,
      duration: timepieceStats.totalDuration.inSeconds,
      offset: timingRunStats.formattedLatestOffset(),
      rateSecPerDay: timepieceStats.averageSecondsPerDay,
    );
  }
}

class StatsGrid extends StatelessWidget {
  final int runs;
  final int points;
  final int duration;
  final String offset;
  final double rateSecPerDay;

  StatsGrid(
      {Key? key,
      required this.runs,
      required this.points,
      required this.duration,
      required this.offset,
      required this.rateSecPerDay})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String rate = rateSecPerDay.toStringAsFixed(1);

    return Container(
      padding: EdgeInsets.all(4.0),
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
                 offset ,
              label: 'Offset:',
              color: Theme.of(context).colorScheme.tertiary,
              labelSize: 14),
          Divider(
            height: 8,
          ),

          Text('All Runs', style: TextStyle(fontSize: 16)),
          TextWithLabel(
            value: '$rate s/d',
            label: 'Sec/Day:',
            color: Theme.of(context).colorScheme.tertiary,
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
