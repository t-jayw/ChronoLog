import 'package:chronolog/components/graphs/custom_line_chart.dart';
import 'package:chronolog/models/timing_measurement.dart';
import 'package:chronolog/providers/timing_measurements_list_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaggedFlSpot extends FlSpot {
  final String tag;

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
    List<TaggedFlSpot> data = createDataPoints(timingMeasurements);

    return CustomLineChart(
      spots: data,
      lineColor: Theme.of(context).colorScheme.secondary,
      titleText: 'Offset (s)',
    );
  }

  List<TaggedFlSpot> createDataPoints(List<TimingMeasurement> measurements) {
    return measurements.map((measurement) {
      final systemTime =
          measurement.system_time.millisecondsSinceEpoch.toDouble();
      final offset = measurement.difference_ms!.toDouble() / 1000;
      final tag = measurement.tag ?? 'No Tag';

      return TaggedFlSpot(systemTime, offset, tag);
    }).toList();
  }
}
