import 'package:chronolog/components/graphs/custom_line_chart.dart';
import 'package:chronolog/providers/timing_measurements_list_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaggedFlSpot extends FlSpot {
  final String? tag;

  TaggedFlSpot(
    double x,
    double y,
    this.tag,
  ) : super(x, y);
}

class OffsetCustomLineChart extends ConsumerWidget {
  final String runId;

  const OffsetCustomLineChart({super.key, required this.runId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timingMeasurements = ref.watch(timingMeasurementsListProvider(runId));

    return CustomLineChart(
      measurements: timingMeasurements,
      lineColor: Theme.of(context).colorScheme.secondary,
      titleText: 'Offset (s)',
    );
  }
}
