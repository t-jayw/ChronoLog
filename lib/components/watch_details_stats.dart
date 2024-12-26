import 'package:chronolog/data_helpers.dart/format_duration.dart';
import 'package:chronolog/data_helpers.dart/timepiece_aggregate_stats.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/timepiece.dart';
import '../providers/timing_run_provider.dart';

class WatchDetailStats extends ConsumerWidget {
  final Timepiece timepiece;
  WatchDetailStats({Key? key, required this.timepiece}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timingRuns = ref.watch(timingRunProvider(timepiece.id));
    final timepieceStats = TimepieceAggregateStats(timepiece, ref);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'All Time',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                Text(
                  "${timingRuns.length} timing runs",
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Divider(
                height: 1,
                thickness: 0.5,
                color: CupertinoColors.separator.resolveFrom(context),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  timingRuns.isEmpty ? '--' : '${timepieceStats.averageSecondsPerDay.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                Text(
                  'sec/day',
                  style: TextStyle(
                    fontSize: 8,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  timingRuns.isEmpty ? '0:00' : formatDuration(timepieceStats.totalDuration).toString(),
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                Text(
                  'duration',
                  style: TextStyle(
                    fontSize: 8,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  timingRuns.isEmpty ? '0' : '${timepieceStats.totalMeasurements}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                Text(
                  'measurements',
                  style: TextStyle(
                    fontSize: 8,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
