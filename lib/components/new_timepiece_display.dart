import 'package:chronolog/components/measurement/measurement_selector_modal.dart';
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
    double? offset;

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

        offset = timingMeasurements.first.difference_ms! / 1000;
      }
    }

    // Handle all time

    return SizedBox(
      height: 130,
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
              padding: const EdgeInsets.all(4.0),
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
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
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
                          SizedBox(height: 2),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${offset != null ? offset.toStringAsFixed(1) : '--'} s',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                    ),
                                  ),
                                  Text(
                                    'Last Offset',
                                    style: TextStyle(
                                      fontSize: 10,
                                    ),
                                  )
                                ],
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${totalDurationDays != null ? totalDurationDays.toStringAsFixed(1) : 0} day${totalDurationDays != 1 ? 's' : ''}',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        Text(' / '),
                                        Text(
                                          '${timingMeasurements.length} points',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ],
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
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween, // This will space out items at start and end of the Row
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start, // Align items to the start of the column
                                        children: [
                                          // Column(
                                          //   children: [
                                          //     Text(
                                          //       '${secondsPerDayForRun != null ? secondsPerDayForRun.toStringAsFixed(1) : "0"}',
                                          //       style: TextStyle(
                                          //         fontWeight: FontWeight.bold,
                                          //         fontSize: 18,
                                          //         color: Theme.of(context)
                                          //             .colorScheme
                                          //             .tertiary,
                                          //       ),
                                          //     ),
                                          //     Text(
                                          //       's/24h',
                                          //       style: TextStyle(
                                          //         fontSize: 10,
                                          //       ),
                                          //     )
                                          //   ],
                                          // ),
                                        ],
                                      ),
                                      Spacer(), // This will push the button to the end of the row
                                      PrimaryButton(
                                        child: Row(
                                          mainAxisSize: MainAxisSize
                                              .min, // Use min to prevent the row from expanding
                                          children: [
                                            Icon(Icons.add,
                                                size: 20,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary), // Addition sign icon
                                            SizedBox(
                                                width:
                                                    4), // Space between icon and text
                                            Text(
                                              'Measurement',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        onPressed: () async {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled:
                                                true, // Set to true to make the bottom sheet full-screen
                                            builder: (BuildContext context) {
                                              // You can return the ManageSettingsScreen or a widget that is more suited for a modal layout
                                              return DraggableScrollableSheet(
                                                expand: false,
                                                builder: (_, controller) =>
                                                    SingleChildScrollView(
                                                  controller: controller,
                                                  child:
                                                      MeasurementSelectorModal(
                                                    timingRunId:
                                                        timingRuns.first.id,
                                                  ), // Ensure your ManageSettingsScreen is suitable for this context
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                      // The CustomToolTip widget can be placed outside of the Row if it needs to be aligned differently or inside based on your UI requirement.
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
