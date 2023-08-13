import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// Import your AtomicClockScreen

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'measurement/measurement_picker.dart';
import '../components/timing_runs_container.dart';
import '../data_helpers.dart/timing_run_parser.dart';
import '../models/timepiece.dart';

import '../models/timing_measurement.dart';
import '../models/timing_run.dart';
import '../providers/timepiece_list_provider.dart';
import '../providers/timing_measurements_list_provider.dart';
import '../providers/timing_run_provider.dart';

class TimepieceDisplayInfo extends ConsumerWidget {
  final Timepiece timepiece;

  const TimepieceDisplayInfo({Key? key, required this.timepiece}) : super(key: key);
  
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
    final timepieces = ref.watch(timepieceListProvider);

    final updatedTimepiece =
        timepieces.firstWhere((tp) => tp.id == timepiece.id);

    final List<TimingRun> timingRuns =
        ref.watch(timingRunProvider(timepiece.id));

    final TimingRun? mostRecentRun =
        timingRuns.isNotEmpty ? timingRuns.first : null;

    List<TimingMeasurement> timingMeasurements = [];
    int? mostRecentDifferenceMs;
    double? secondsPerDayForRun;
    double? totalDurationDays;
    String timeSinceLastMeasurement = '';

    if (mostRecentRun != null) {
      // Get the TimingMeasurements of the most recent run
      timingMeasurements =
          ref.watch(timingMeasurementsListProvider(mostRecentRun.id));

      // Get the most recent TimingMeasurement
      final TimingMeasurement? mostRecentMeasurement =
          timingMeasurements.isNotEmpty ? timingMeasurements.first : null;

      if (mostRecentMeasurement != null) {
        // Get the offset of the most recent TimingMeasurement
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
    }

    return Expanded(
      child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: Row(
                      children: [
                        
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
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      timepiece.brand,
                                      maxLines: 1,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 16,
                                        // color: Theme.of(context)
                                        //     .colorScheme
                                        //     .onBackground,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4.0),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            '${secondsPerDayForRun != null ? secondsPerDayForRun.toStringAsFixed(1) : "0"}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' s/d',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            '${timingMeasurements.length} points',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            ' / ${totalDurationDays != null ? totalDurationDays.toStringAsFixed(1) : 0} day${totalDurationDays != 1 ? 's' : ''}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  timeSinceLastMeasurement,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                  ),
                                ),
                                if (mostRecentRun != null)
                                  Container(
                                    alignment: Alignment.bottomRight,
                                    child: Padding(
                                      padding: EdgeInsets.all(0.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ElevatedButton(
                                            style: Theme.of(context)
                                                .elevatedButtonTheme
                                                .style, // add this line
    
                                            child: Align(
                                                alignment: Alignment.bottomRight,
                                                child: Row(children: [
                                                  Text('Add Measurement',
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          color: Theme.of(context)
                                                              .colorScheme
                                                              .onBackground)),
                                                  Icon(Icons.check_circle,
                                                      size: 14,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onBackground)
                                                ])),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    //title: Text('Add Measurement'),
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
                                          ),
                                        ],
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
                const SizedBox(height: 15),
                Divider(),
                Expanded(
                  child: TimingRunsContainer(timepiece: timepiece),
                ),
              ],
      ),
    );
  }
}
