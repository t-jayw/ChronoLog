import 'package:chronolog/components/graphs/offset_custom_line_chart.dart';
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

    TimingRunStatistics timingRunStats =
        TimingRunStatistics(mostRecentRunMeasurements);

    List<String> complianceStatuses = timingRunStats.checkCompliance();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with stats
          
          
          
          // Compliance row
          if (complianceStatuses.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.tertiary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: complianceStatuses.map((status) => 
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.tertiary,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                ).toList(),
              ),
            ),
          
          
          // Graph
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: OffsetCustomLineChart(runId: mostRecentRun.id),
              ),
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