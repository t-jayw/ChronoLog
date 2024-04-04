import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chronolog/providers/timing_measurements_list_provider.dart';
import '../ads/footer_banner_ad.dart';
import '../delete_confirmation_dialog.dart';
import 'timing_measurement_item.dart'; // Import the TimingMeasurementItem widget

class TimingMeasurementsContainer extends ConsumerWidget {
  const TimingMeasurementsContainer({Key? key, required this.timingRunId})
      : super(key: key);

  final String timingRunId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timingMeasurements = ref.watch(timingMeasurementsListProvider(timingRunId));

    return timingMeasurements.isNotEmpty
        ? Scrollbar(
            thumbVisibility: true,
            child: ListView.builder(
              itemCount: timingMeasurements.length,
              itemBuilder: (context, index) {
                final timingMeasurement = timingMeasurements[index];

                return Dismissible(
                  key: Key(timingMeasurement.id),
                  confirmDismiss: (direction) async {
                    return await showCupertinoDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return DeleteConfirmationDialog();
                      },
                    );
                  },
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    ref
                        .read(timingMeasurementsListProvider(timingRunId).notifier)
                        .deleteTimingMeasurement(timingMeasurement.id);
                  },
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20.0),
                    color: Colors.red,
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  child: TimingMeasurementItem(timingMeasurement: timingMeasurement),
                );
              },
            ),
          )
        : Center(
            child: Text('No timing measurements available.'),
          );
  }
}
