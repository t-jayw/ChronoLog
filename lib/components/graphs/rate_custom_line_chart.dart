import 'package:chronolog/components/graphs/custom_line_chart.dart';
import 'package:chronolog/components/graphs/offset_custom_line_chart.dart';
import 'package:chronolog/models/timing_measurement.dart';
import 'package:chronolog/providers/timing_measurements_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RateCustomLineChart extends ConsumerWidget {
  final String runId;

  const RateCustomLineChart({super.key, required this.runId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timingMeasurements = ref.watch(timingMeasurementsListProvider(runId));
    List<TaggedFlSpot> data = calculateRateOfChange(timingMeasurements);

    return CustomLineChart(
      spots: data,
      lineColor: Theme.of(context).colorScheme.secondary,
      titleText: 'Rate of Change (s/d)',
      showSlope: false,
      showAverageLine: true,

    );
  }

  List<TaggedFlSpot> calculateRateOfChange(
      List<TimingMeasurement> timingMeasurements) {
    if (timingMeasurements.length < 2)
      return []; // Need at least two measurements to calculate rate of change

    List<TaggedFlSpot> data = List.generate(timingMeasurements.length - 1, (i) {
      final currentMeasurement = timingMeasurements[i];
      final nextMeasurement = timingMeasurements[i + 1];

      final currentSystemTime =
          currentMeasurement.system_time.millisecondsSinceEpoch.toDouble();
      final currentOffset = currentMeasurement.difference_ms!.toDouble() / 1000;

      final nextSystemTime =
          nextMeasurement.system_time.millisecondsSinceEpoch.toDouble();
      final nextOffset = nextMeasurement.difference_ms!.toDouble() / 1000;

      final timeDifference = (nextSystemTime - currentSystemTime) /
          1000 /
          60 /
          60 /
          24; // Time difference in days
      final rateOfChange = (nextOffset - currentOffset) /
          timeDifference; // Rate of change per day

      final tag = currentMeasurement.tag ?? 'No Tag';

      return TaggedFlSpot(currentSystemTime, rateOfChange, tag);
    });

    // Optionally, add a final spot with zero change or just end the data list
    final lastMeasurement = timingMeasurements.last;
    final lastSystemTime =
        lastMeasurement.system_time.millisecondsSinceEpoch.toDouble();
    data.add(TaggedFlSpot(lastSystemTime, 0, lastMeasurement.tag ?? 'No Tag'));

    return data;
  }
}
