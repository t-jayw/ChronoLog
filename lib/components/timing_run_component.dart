import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chronolog/providers/timing_measurements_list_provider.dart';
import 'package:intl/intl.dart';

import '../data_helpers.dart/timing_run_parser.dart';
import '../models/timepiece.dart';
import '../models/timing_measurement.dart';
import '../models/timing_run.dart';
import '../screens/timing_run_details_screen.dart';
import 'measurement/measurement_picker.dart';
import 'primary_button.dart'; // Assuming you have this file

class TimingRunComponent extends ConsumerStatefulWidget {
  const TimingRunComponent(
      {super.key,
      required this.timingRun,
      required this.timepiece,
      this.isMostRecent // This is the updated line
      });

  final TimingRun timingRun;
  final Timepiece timepiece;
  final bool? isMostRecent;

  @override
  _TimingRunComponentState createState() => _TimingRunComponentState();
}

class _TimingRunComponentState extends ConsumerState<TimingRunComponent> {
  bool showTimingMeasurements = false;

  @override
  Widget build(BuildContext context) {
    // Fetch the state of the TimingMeasurementListProvider (List of TimingMeasurements)
    final timingMeasurements =
        ref.watch(timingMeasurementsListProvider(widget.timingRun.id));

    String _formatDuration(Duration d) {
      String result = '';
      if (d.inDays > 0) {
        result = '${d.inDays} day${d.inDays != 1 ? 's' : ''} ago';
      } else if (d.inHours > 0) {
        result = '${d.inHours} hour${d.inHours != 1 ? 's' : ''} ago';
      } else if (d.inMinutes > 0) {
        result = '${d.inMinutes} minute${d.inMinutes != 1 ? 's' : ''} ago';
      } else {
        result = 'Just now';
      }
      return result;
    }

    int? mostRecentDifferenceMs;
    double? secondsPerDayForRun;
    double? totalDurationDays;
    String timeSinceLastMeasurement = '';

    // Get the most recent TimingMeasurement
    final TimingMeasurement? mostRecentMeasurement =
        timingMeasurements.isNotEmpty ? timingMeasurements.first : null;

    if (mostRecentMeasurement != null) {
      mostRecentDifferenceMs = mostRecentMeasurement.difference_ms!;

      secondsPerDayForRun = calculateRatePerDay(timingMeasurements);

      totalDurationDays =
          calculateTotalDuration(timingMeasurements) / 60 / 60 / 24;
    }

    if (mostRecentMeasurement != null) {
      timeSinceLastMeasurement = _formatDuration(
        DateTime.now().difference(mostRecentMeasurement.system_time),
      );
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TimingRunDetails(timingRun: widget.timingRun, timepiece: widget.timepiece,),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Container(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12.0, horizontal: 14.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Timing Run',
                          style: TextStyle(fontSize: 12),
                        ),
                        Icon(Icons.chevron_right), // Add a > icon here
                      ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${secondsPerDayForRun != null ? secondsPerDayForRun.toStringAsFixed(1) : "0"}',
                              style: TextStyle(
                                  fontSize: 34,
                                  color: Theme.of(context).colorScheme.tertiary,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'sec/day',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${totalDurationDays != null ? totalDurationDays.toStringAsFixed(1) : 0} day${totalDurationDays != 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 24,
                                color: Theme.of(context).colorScheme.tertiary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${timingMeasurements.length} points',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  fontSize: 12),
                            ),
                            Text('${timeSinceLastMeasurement}',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                    fontSize: 12))
                          ],
                        ),
                      ],
                    ),
                    (widget.isMostRecent ?? false)
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: PrimaryButton(
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          actions: <Widget>[
                                            MeasurementPicker(
                                              timingRunId: widget.timingRun.id,
                                            )
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Text(
                                    'Add Measurement',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
