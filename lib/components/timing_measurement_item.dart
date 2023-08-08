import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/timing_measurement.dart';
import '../providers/timing_measurements_list_provider.dart';
import 'forms/edit_timing_measurement_form.dart';

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
    final contentList = <Widget>[];
    String tag = timingMeasurement.tag != null ? timingMeasurement.tag! : '';

    if (index < sortedMeasurements.length - 1) {
      final previousMeasurement = sortedMeasurements[index + 1];
      final difference = (timingMeasurement.difference_ms! -
              previousMeasurement.difference_ms!) /
          1000;
      final differenceSeconds = difference.toStringAsFixed(1);

      final timeSincePrevious = timingMeasurement.system_time
          .difference(previousMeasurement.system_time)
          .inSeconds;

      final rateOfChange = (difference / (timeSincePrevious / (24 * 60 * 60)))
          .toStringAsFixed(1);

      contentList.addAll([
        _buildMetricColumn(
            'Offset',
            '${(timingMeasurement.difference_ms! / 1000).toStringAsFixed(1)} s',
            colorScheme.onSurface,
            colorScheme.tertiary),
        VerticalDivider(
          color: Colors.black,
          width: 10,
          thickness: 2,
        ),
        _buildMetricColumn('Change', differenceSeconds + ' s',
            colorScheme.onSurface, colorScheme.tertiary),
        VerticalDivider(),
        _buildMetricColumn('Rate', rateOfChange + ' s/d', colorScheme.onSurface,
            colorScheme.tertiary),
      ]);
    } else {
      contentList.addAll([
        _buildMetricColumn(
            'Offset',
            '${(timingMeasurement.difference_ms! / 1000).toStringAsFixed(1)} s',
            colorScheme.onSurface,
            colorScheme.tertiary),
        _buildMetricColumn(
            'Change', '--' + ' s', colorScheme.tertiary, colorScheme.onSurface),
        _buildMetricColumn(
            'Rate', '--' + 's/d', colorScheme.onSurface, colorScheme.tertiary),
      ]);
    }

    if (tag.isNotEmpty) {
      contentList.add(_buildTag(tag, context));
    }

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                EditTimingMeasurementForm(timingMeasurement: timingMeasurement),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 1.0, horizontal: 2.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 4.0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            padding: EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Text(
                //   // Title
                //   'Measurement',
                //   style: TextStyle(
                //     fontSize: 10.0,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Measurement: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(timingMeasurement.system_time)}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 10.0,
                      ),
                    ),
                    Icon(
                      Icons.edit,
                      size: 16,
                    ),
                  ],
                ),
                Divider(color: Colors.black), // Divider

                Row(
                  children: contentList,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                ),

                SizedBox(height: 1.0),
                // Text(
                //   '${DateFormat('yyyy-MM-dd HH:mm:ss').format(timingMeasurement.system_time)}',
                //   style: TextStyle(
                //     color: Colors.black,
                //     fontSize: 10.0,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardText(String label, String value, ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.0),
      child: RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
              text: label,
              style: TextStyle(
                color: colorScheme.inverseSurface,
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: ' ' + value,
              style: TextStyle(
                color: colorScheme.tertiary,
                fontSize: 14.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardInlineText(String changeLabel, String changeValue,
      String rateLabel, String rateValue, String tag, ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: changeLabel,
                  style: TextStyle(
                    color: colorScheme.inverseSurface,
                    fontSize: 12.0,
                  ),
                ),
                TextSpan(
                  text: ' ' + changeValue,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ),
          RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: rateLabel,
                  style: TextStyle(
                    color: colorScheme.inverseSurface,
                    fontSize: 12.0,
                  ),
                ),
                TextSpan(
                  text: ' ' + rateValue,
                  style: TextStyle(
                    color: colorScheme.tertiary,
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          ),
          tag.isNotEmpty
              ? Text(
                  tag,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: colorScheme.tertiary,
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(
      String label, String value, Color metricColor, Color labelColor) {
    return Column(
      children: <Widget>[
        AutoSizeText(
          value,
          style: TextStyle(// Larger font size
            color: metricColor, // Tertiary color
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.0, // Smaller font size
            color: labelColor, // onSurface color
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String tag, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        tag,
        style: TextStyle(
            fontSize: 10, color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }
}
