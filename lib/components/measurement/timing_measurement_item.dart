import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/timing_measurement.dart';
import '../../providers/timing_measurements_list_provider.dart';
import '../forms/edit_timing_measurement_form.dart';

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
      padding: EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Measurement',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (enableNavigation)
                Icon(CupertinoIcons.chevron_right, size: 16),
            ],
          ),
          Divider(height: 4, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${(timingMeasurement.difference_ms! / 1000).toStringAsFixed(1)}',
                    style: TextStyle(
                      fontSize: 24,
                      color: colorScheme.tertiary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'seconds offset',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onBackground,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (prevMeasurement != null) ...[
                    Row(
                      children: [
                        Text(
                          '$differenceSeconds',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.tertiary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ' change',
                          style: TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '$rateOfChange',
                          style: TextStyle(
                            color: colorScheme.onBackground,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          ' sec/day',
                          style: TextStyle(
                            color: colorScheme.onBackground,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                  Text(
                    timingMeasurement.user_input_time.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onBackground,
                    ),
                  ),
                ],
              ),
              if (timingMeasurement.tag?.isNotEmpty ?? false)
                _buildTag(timingMeasurement.tag!, context),
            ],
          ),
        ],
      ),
    );

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: colorScheme.tertiary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: enableNavigation
          ? InkWell(
              onTap: () => Navigator.of(context).push(
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Theme.of(context).colorScheme.tertiary.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 11,
          color: Theme.of(context).colorScheme.tertiary,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
