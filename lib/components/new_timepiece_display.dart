import 'package:chronolog/components/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import for Riverpod

import '../data_helpers.dart/timing_run_parser.dart';
import '../models/timepiece.dart';
import '../models/timing_run.dart';
import '../models/timing_measurement.dart';
import '../providers/timing_run_provider.dart';
import '../screens/watch_details_screen.dart';

import '../providers/timing_measurements_list_provider.dart';
import 'custom_tool_tip.dart';
import 'measurement_picker.dart';

class NewTimepieceDisplay extends ConsumerWidget {
  final Timepiece timepiece;

  const NewTimepieceDisplay({Key? key, required this.timepiece})
      : super(key: key);

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<TimingRun> timingRuns =
        ref.watch(timingRunProvider(timepiece.id));

    // Handle the most recent timing run
    final TimingRun? mostRecentRun =
        timingRuns.isNotEmpty ? timingRuns.first : null;

    List<TimingMeasurement> timingMeasurements = [];
    double? secondsPerDayForRun;
    double? totalDurationDays;
    String timeSinceLastMeasurement = '';

    if (mostRecentRun != null) {
      timingMeasurements =
          ref.watch(timingMeasurementsListProvider(mostRecentRun.id));

      if (timingMeasurements.isNotEmpty) {
        secondsPerDayForRun = calculateRatePerDay(timingMeasurements);
        totalDurationDays =
            calculateTotalDuration(timingMeasurements) / 60 / 60 / 24;

        timeSinceLastMeasurement = _formatDuration(
          DateTime.now().difference(timingMeasurements.first.system_time),
        );
      }
    }

    // Handle all time

    return SizedBox(
      height: 180,
      width: double.infinity,
      child: Card(
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WatchDetails(timepiece: timepiece),
              ),
            );
          },
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: timepiece.image != null
                        ? Image.memory(
                            timepiece.image!,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'assets/images/placeholder.png',
                            fit: BoxFit.cover,
                          ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                timepiece.model,
                                maxLines: 2,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                ),
                              ),
                              const SizedBox(width: 1),
                              Expanded(
                                child: Text(
                                  timepiece.brand,
                                  maxLines: 1,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                ),
                              ),
                              Icon(Icons.chevron_right,
                                  size: 24,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${secondsPerDayForRun != null ? secondsPerDayForRun.toStringAsFixed(1) : "0"}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                    ),
                                  ),
                                  Text(
                                    'sec/day',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${totalDurationDays != null ? totalDurationDays.toStringAsFixed(1) : 0} day${totalDurationDays != 1 ? 's' : ''}',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      '${timingMeasurements.length} points',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      timeSinceLastMeasurement,
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (mostRecentRun != null)
                            Expanded(
                              child: Container(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: EdgeInsets.all(2.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(child: Container()),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          PrimaryButton(
                                            child: Text(
                                              'Add Measurement',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary),
                                            ),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    actions: <Widget>[
                                                      MeasurementPicker(
                                                        timingRunId:
                                                            timingRuns.first.id,
                                                      )
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          )
                                        ],
                                      ),
                                      CustomToolTip(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        child: Text(
                                          "Add to current timing run",
                                          style: TextStyle(
                                              fontSize:
                                                  12.0), // you can style your text here
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
