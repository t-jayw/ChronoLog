import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chronolog/providers/timing_measurements_list_provider.dart';
import '../delete_confirmation_dialog.dart';
import 'timing_measurement_item.dart'; // Import the TimingMeasurementItem widget
import 'package:chronolog/models/timing_measurement.dart'; // Add this import

class TimingMeasurementsContainer extends ConsumerWidget {
  const TimingMeasurementsContainer({Key? key, required this.timingRunId})
      : super(key: key);

  final String timingRunId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final measurements = ref.watch(timingMeasurementsListProvider(timingRunId));

    if (measurements.isEmpty) {
      return const Center(child: Text('No timing measurements available.'));
    }

    return Scrollbar(
      thumbVisibility: true,
      child: ListView.builder(
        itemCount: measurements.length,
        itemBuilder: (_, index) => _buildDismissibleItem(
          context,
          ref,
          measurements[index],
        ),
      ),
    );
  }

  Widget _buildDismissibleItem(
    BuildContext context,
    WidgetRef ref,
    TimingMeasurement measurement,
  ) {
    return Dismissible(
      key: Key(measurement.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => showCupertinoDialog<bool>(
        context: context,
        builder: (_) => const DeleteConfirmationDialog(),
      ),
      onDismissed: (_) => ref
          .read(timingMeasurementsListProvider(timingRunId).notifier)
          .deleteTimingMeasurement(measurement.id),
 background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Icon(Icons.delete,
                      color: Theme.of(context).colorScheme.error, size: 40),
                ),
      child: TimingMeasurementItem(timingMeasurement: measurement),
    );
  }
}
