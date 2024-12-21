import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/timing_measurement.dart';
import '../../providers/timing_measurements_list_provider.dart';
import '../forms/edit_timing_measurement_form.dart';

class TimingMeasurementItem extends ConsumerWidget {
  const TimingMeasurementItem({Key? key, required this.timingMeasurement})
      : super(key: key);

  final TimingMeasurement timingMeasurement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final timingMeasurementsProvider =
        ref.read(timingMeasurementsListProvider(timingMeasurement.run_id));

    final sortedMeasurements = timingMeasurementsProvider.toList()
      ..sort((a, b) => b.system_time.compareTo(a.system_time));
    final index = sortedMeasurements.indexOf(timingMeasurement);

    String? differenceSeconds;
    String? rateOfChange;

    if (index < sortedMeasurements.length - 1) {
      final previousMeasurement = sortedMeasurements[index + 1];
      final difference = (timingMeasurement.difference_ms! -
              previousMeasurement.difference_ms!) /
          1000;
      differenceSeconds = difference.toStringAsFixed(1);

      final timeSincePrevious = timingMeasurement.system_time
          .difference(previousMeasurement.system_time)
          .inSeconds;
      rateOfChange = (difference / (timeSincePrevious / (24 * 60 * 60)))
          .toStringAsFixed(1);
    }

    return Card(
      elevation: 0.5,
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => EditTimingMeasurementForm(timingMeasurement: timingMeasurement),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMM d, h:mm a').format(timingMeasurement.system_time),
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 13.0,
                    ),
                  ),
                  Icon(CupertinoIcons.chevron_right, size: 16),
                ],
              ),
              Divider(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMetricItem('Offset', 
                    '${(timingMeasurement.difference_ms! / 1000).toStringAsFixed(1)}s',
                    colorScheme),
                  if (index < sortedMeasurements.length - 1) ...[
                    _buildMetricItem('Change', '$differenceSeconds s', colorScheme),
                    _buildMetricItem('Rate', '$rateOfChange s/d', colorScheme),
                  ],
                  if (timingMeasurement.tag?.isNotEmpty ?? false)
                    _buildTag(timingMeasurement.tag!, context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 4.0),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.0,
            color: colorScheme.onSurface.withOpacity(0.6),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String tag, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
