import 'package:chronolog/data_helpers.dart/timepiece_aggregate_stats.dart';
import 'package:chronolog/data_helpers.dart/timing_run_parser.dart';
import 'package:chronolog/models/timepiece.dart';
import 'package:chronolog/models/timing_measurement.dart';
import 'package:chronolog/models/timing_run.dart';
import 'package:chronolog/providers/timing_measurements_list_provider.dart';
import 'package:chronolog/providers/timing_run_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShareModalStats extends ConsumerWidget {
  final Timepiece timepiece;
  ShareModalStats({Key? key, required this.timepiece}) : super(key: key);

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
      return AllRunsStatsGrid(
        runs: 0,
        points: 0,
        duration: 0,
        rateSecPerDay: 0,
      );
    }

    return MostRecentRunShareStats(
        timingRun: timingRuns.first,
        timingRunMeasurements: mostRecentRunMeasurements);
  }
}

class MostRecentRunShareStats extends StatelessWidget {
  final TimingRun timingRun;
  final List<TimingMeasurement> timingRunMeasurements;

  const MostRecentRunShareStats(
      {Key? key, required this.timingRun, required this.timingRunMeasurements})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    TimingRunStatistics timingRunStats =
        TimingRunStatistics(timingRunMeasurements);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
            mainAxisAlignment: MainAxisAlignment.end,

        children: [
          Column(
            children: [
              Text(timingRunStats.formattedSecondsPerDayForRun(),
                  style: TextStyle(
                      fontSize: 24,
                      color: Theme.of(context).colorScheme.tertiary,
                      fontWeight: FontWeight.bold)),
              Text('sec/day',
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onBackground)),
            ],
          ),
          Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(timingRunStats.formattedTotalDuration(),
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.tertiary,
                          fontWeight: FontWeight.bold)),
                  Text(' duration',
                      style: TextStyle(
                        fontSize: 10,
                      )),
                ],
              ),
              Row(
                children: [
                  Text('${timingRunStats.totalPoints}',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: 12)),
                  Text(' points',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: 10)),
                ],
              ),
              Row(
                children: [
                  Text(timingRunStats.formattedTimeSinceLastMeasurement(),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: 12)),
                  Text(' ago',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: 10)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AllRunsStatsGrid extends StatelessWidget {
  final int runs;
  final int points;
  final int duration;

  final double rateSecPerDay;

  AllRunsStatsGrid(
      {Key? key,
      required this.runs,
      required this.points,
      required this.duration,
      required this.rateSecPerDay})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String rate = rateSecPerDay.toStringAsFixed(1);

    return Container(
      padding: EdgeInsets.all(4.0),
    );
  }
}
