import 'package:chronolog/components/graphs/offset_custom_line_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

class TaggedFlSpot extends FlSpot {
  final String tag;

  TaggedFlSpot(
    double x,
    double y,
    this.tag,
  ) : super(x, y);
}

class TimingRunMeasurementsOffsetGraph extends ConsumerWidget {
  final String runId;

  const TimingRunMeasurementsOffsetGraph({super.key, required this.runId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4.0, 12.0, 4.0),
        child: SizedBox(
          width: double.infinity,
          child: OffsetCustomLineChart(
            runId: runId,
          ),
        ),
      ),
    );
  }
}
