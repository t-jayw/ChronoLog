import 'package:chronolog/data_helpers.dart/format_duration.dart';
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

    int allMeasurements = 0;
    int allRunsDuration = 0;
    int allRunsDifferenceInSeconds = 0;
    double allDaysRun = 0;

    TimingRun? mostRecentRun;
    List<TimingMeasurement> mostRecentRunMeasurements = [];

    if (timingRuns.isEmpty) {
    } else {
      mostRecentRun = timingRuns.first;
      mostRecentRunMeasurements =
          ref.watch(timingMeasurementsListProvider(mostRecentRun.id));

      timingRuns.forEach((run) {
        int totalDuration;
        double totalDurationDays;

        final timingMeasurements =
            ref.watch(timingMeasurementsListProvider(run.id));

        TimingRunStatistics timingRunStats =
            TimingRunStatistics(timingMeasurements);

        totalDuration = timingRunStats.totalDuration.inSeconds;

        totalDurationDays = totalDuration / 60 / 60 / 24;

        allMeasurements += timingMeasurements.length;
        allRunsDuration += totalDuration;
        allDaysRun += totalDurationDays;
        allRunsDifferenceInSeconds += timingRunStats.totalSecondsChange;
      });
    }
    double secPerDay =
        allDaysRun != 0.0 ? allRunsDifferenceInSeconds / allDaysRun : 0.0;

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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Change: ',
                    style: TextStyle(
                      fontSize: 12,
                    )),
                Text('${timingRunStats.formattedSecondsPerDayForRun()} s/d',
                    style: TextStyle(
                      fontSize: 18,
                    )),
              ],
            ),
            Row(
              children: [
                Text('Duration: ', style: TextStyle(fontSize: 12)),
                Text(timingRunStats.formattedTotalDuration(),
                    style: TextStyle(fontSize: 18)),
              ],
            ),
          ],
        ),
        Column(
          children: [
            Row(
              children: [
                Text(timingRunStats.totalPoints.toString(),
                    style: TextStyle(fontSize: 18)),
                Text(' Measurements', style: TextStyle(fontSize: 12)),
              ],
            ),
            Row(
              children: [
                Text(timingRunStats.firstMeasurementDateTime,
                    style: TextStyle(fontSize: 12)),
                Text(' Started', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ],
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
