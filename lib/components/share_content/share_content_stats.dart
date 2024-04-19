import 'dart:ffi';

import 'package:chronolog/components/graphs/offset_custom_line_chart.dart';
import 'package:chronolog/data_helpers.dart/timepiece_aggregate_stats.dart';
import 'package:chronolog/data_helpers.dart/timing_run_parser.dart';
import 'package:chronolog/models/timepiece.dart';
import 'package:chronolog/models/timing_measurement.dart';
import 'package:chronolog/models/timing_run.dart';
import 'package:chronolog/providers/timing_measurements_list_provider.dart';
import 'package:chronolog/providers/timing_run_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

    return MostRecentRunShareStats(
        timingRun: timingRuns.first,
        timingRunMeasurements: mostRecentRunMeasurements);
  }
}

class MostRecentRunShareStats extends StatelessWidget {
  final TimingRun timingRun;
  final List<TimingMeasurement> timingRunMeasurements;

  const MostRecentRunShareStats({
    Key? key,
    required this.timingRun,
    required this.timingRunMeasurements,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TimingRunStatistics timingRunStats =
        TimingRunStatistics(timingRunMeasurements);

    List<Widget> certificationWidgets = [SizedBox(height: 2)];

    List<String> complianceStatuses = timingRunStats.checkCompliance() ?? [];
    for (var status in complianceStatuses) {
      certificationWidgets.add(
        Row(
          children: [
            Icon(
              Icons.check,
              color: Colors.green,
              size: 10,
            ),
            SizedBox(width: 4),
            Text(status, style: TextStyle(fontSize: 10)),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  Text(timingRunStats.formattedSecondsPerDayForRun(),
                      style: TextStyle(
                          fontSize: 24,
                          color: Theme.of(context).colorScheme.tertiary,
                          fontWeight: FontWeight.bold)),
                  SizedBox(width: 4),
                  Text('sec/day',
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onBackground)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: certificationWidgets,
              ),
            ],
          ),
          Expanded(
            child: Row(
              children: [
                // Stats Column

                SizedBox(width: 20),
                OffsetCustomLineChart(runId: timingRun.id),
                SizedBox(width: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

        // Column(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: certificationWidgets,
        //   )
        //   else   