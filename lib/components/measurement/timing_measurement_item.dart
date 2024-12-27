import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/timing_measurement.dart';
import '../../providers/timing_measurements_list_provider.dart';
import '../forms/edit_timing_measurement_form.dart';
import '../formatted_time_display.dart';

class TimingMeasurementItem extends ConsumerWidget {
  const TimingMeasurementItem({
    Key? key, 
    required this.timingMeasurement,
    this.enableNavigation = true,
    this.previousMeasurement,
  }) : super(key: key);

  final TimingMeasurement timingMeasurement;
  final bool enableNavigation;
  final TimingMeasurement? previousMeasurement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    
    String? differenceSeconds;
    String? rateOfChange;

    TimingMeasurement? prevMeasurement = previousMeasurement;
    if (prevMeasurement == null && enableNavigation) {
      final timingMeasurementsProvider =
          ref.read(timingMeasurementsListProvider(timingMeasurement.run_id));

      final sortedMeasurements = timingMeasurementsProvider.toList()
        ..sort((a, b) => b.system_time.compareTo(a.system_time));
      final index = sortedMeasurements.indexOf(timingMeasurement);
      
      if (index < sortedMeasurements.length - 1) {
        prevMeasurement = sortedMeasurements[index + 1];
      }
    }

    if (prevMeasurement != null) {
      final difference = (timingMeasurement.difference_ms! -
              prevMeasurement.difference_ms!) /
          1000;
      differenceSeconds = difference.toStringAsFixed(1);

      final timeSincePrevious = timingMeasurement.system_time
          .difference(prevMeasurement.system_time)
          .inSeconds;
      rateOfChange = (difference / (timeSincePrevious / (24 * 60 * 60)))
          .toStringAsFixed(1);
    }

    Widget content = Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'System time: ',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onBackground.withOpacity(0.7),
                          ),
                        ),
                        FormattedTimeDisplay(
                          dateTime: timingMeasurement.system_time,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onBackground.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    if (timingMeasurement.tag?.isNotEmpty ?? false)
                      Padding(
                        padding: EdgeInsets.only(top: 4.0),
                        child: _buildTag(timingMeasurement.tag!, context),
                      ),
                  ],
                ),
              ),
              if (enableNavigation)
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 16,
                  color: colorScheme.onBackground.withOpacity(0.3),
                ),
            ],
          ),
          
          Divider(height: 4, thickness: 1),
          
          Row(
            children: [
              Expanded(
                child: _buildMeasurementColumn(
                  value: (timingMeasurement.difference_ms! / 1000).toStringAsFixed(1),
                  label: 'offset (sec)',
                  valueColor: colorScheme.secondary,
                  context: context,
                ),
              ),
              if (prevMeasurement != null) ...[
                SizedBox(width: 12),
                Expanded(
                  child: _buildMeasurementColumn(
                    value: differenceSeconds!,
                    label: 'change (sec)',
                    valueColor: colorScheme.secondary,
                    context: context,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildMeasurementColumn(
                    value: rateOfChange!,
                    label: 'sec/day',
                    valueColor: colorScheme.tertiary,
                    context: context,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: enableNavigation
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (_) => EditTimingMeasurementForm(
                    timingMeasurement: timingMeasurement,
                  ),
                ),
              ),
              child: content,
            )
          : content,
    );
  }

  Widget _buildTag(String tag, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: Text(
          tag,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.tertiary,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildMeasurementColumn({
    required String value,
    required String label,
    required Color valueColor,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            color: valueColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
      ],
    );
  }
}
