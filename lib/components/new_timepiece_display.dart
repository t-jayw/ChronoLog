import 'package:chronolog/components/measurement/measurement_selector_modal.dart';
import 'package:chronolog/components/premium/premium_needed_dialog.dart';
import 'package:chronolog/components/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<TimingRun> timingRuns =
        ref.watch(timingRunProvider(timepiece.id));

    // Handle the most recent timing run
    final TimingRun? mostRecentRun =
        timingRuns.isNotEmpty ? timingRuns.first : null;

    List<TimingMeasurement> timingMeasurements = [];

    /// USE timing run parser stats

    if (mostRecentRun != null) {
      timingMeasurements =
          ref.watch(timingMeasurementsListProvider(mostRecentRun.id));
      if (timingMeasurements.length > 0) {}
    }

    TimingRunStatistics timingRunStats =
        TimingRunStatistics(timingMeasurements);

    // Handle all time

    return SizedBox(
      height: 140,
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
              padding: const EdgeInsets.all(6.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: timepiece.image != null
                        ? Image.memory(
                            timepiece.image!,
                            fit: BoxFit.contain,
                          )
                        : Image.asset(
                            'assets/images/placeholder.png',
                            fit: BoxFit.contain,
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
                          Divider(
                            height: 1,
                            thickness: .4,
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Active Timing Run',
                                style: TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${timingRunStats.formattedSecondsPerDayForRun()}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiary,
                                        ),
                                      ),
                                      Text(
                                        ' sec/day',
                                        style: TextStyle(
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            '${timingRunStats.formattedLatestOffset()}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            ' offset',
                                            style: TextStyle(
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        '${timingRunStats.formattedTimeSinceLastMeasurement()}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        ' ago',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              PrimaryButton(
                                child: Row(
                                  mainAxisSize: MainAxisSize
                                      .min, // Use min to prevent the row from expanding
                                  children: [
                                    Icon(Icons.add,
                                        size: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary), // Addition sign icon
                                    SizedBox(
                                        width:
                                            2), // Space between icon and text
                                    Text(
                                      '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                onPressed: () async {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  bool? isPremiumActivated =
                                      prefs.getBool('isPremiumActive');
                                  print(timingMeasurements.length);
                                  if (isPremiumActivated != true &&
                                      timingMeasurements.length > 4) {
                                    showPremiumNeededDialog(context,
                                        "Free version limited to 5 measurements per Timing Run");
                                    Posthog().capture(
                                      eventName: 'paywall',
                                      properties: {
                                        'reason': 'num_measurements_paywall',
                                      },
                                    );
                                  } else {
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
                                            child: MeasurementSelectorModal(
                                              timingRunId: timingRuns.first.id,
                                            ), // Ensure your ManageSettingsScreen is suitable for this context
                                          ),
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                            ],
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
