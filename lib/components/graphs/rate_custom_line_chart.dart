import 'package:chronolog/components/graphs/custom_line_chart.dart';
import 'package:chronolog/components/graphs/offset_custom_line_chart.dart';
import 'package:chronolog/models/timing_measurement.dart';
import 'package:chronolog/providers/timing_measurements_list_provider.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RateCustomLineChart extends ConsumerWidget {
  final String runId;

  const RateCustomLineChart({super.key, required this.runId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timingMeasurements = ref.watch(timingMeasurementsListProvider(runId));

    return CustomLineChart(
      measurements: timingMeasurements,
      lineColor: Theme.of(context).colorScheme.secondary,
      titleText: 'Rate of Change (s/d)',
      chartType: 'rate',
    );
  }

}
