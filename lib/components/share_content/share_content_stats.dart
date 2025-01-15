import 'package:chronolog/components/graphs/offset_custom_line_chart.dart';
import 'package:chronolog/models/timepiece.dart';
import 'package:chronolog/models/timing_run.dart';
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


    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with stats
          
          
          
          // Compliance row
          
          
          
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