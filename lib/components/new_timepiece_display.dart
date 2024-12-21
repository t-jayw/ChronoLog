import 'package:chronolog/components/measurement/measurement_selector_modal.dart';
import 'package:chronolog/components/premium/premium_needed_dialog.dart';
import 'package:chronolog/components/primary_button.dart';
import 'package:flutter/cupertino.dart';
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

    return Container(
      height: 120,
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => WatchDetails(timepiece: timepiece),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  height: 104,
                  width: 104,
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
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        timepiece.model,
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context).colorScheme.onBackground,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      timepiece.brand,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                CupertinoIcons.chevron_right,
                                size: 20,
                                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Divider(
                              height: 1,
                              thickness: 0.5,
                              color: CupertinoColors.separator.resolveFrom(context),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Active Timing Run',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${timingRunStats.formattedSecondsPerDayForRun()}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 17,
                                        color: Theme.of(context).colorScheme.tertiary,
                                      ),
                                    ),
                                    Text(
                                      'sec/day',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          timingRunStats.formattedLatestOffset() ?? '-',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            color: Theme.of(context).colorScheme.onBackground,
                                          ),
                                        ),
                                        Text(
                                          ' offset',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Last ',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                                          ),
                                        ),
                                        Text(
                                          timingRunStats.formattedTimeSinceLastMeasurement() ?? '-',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            color: Theme.of(context).colorScheme.onBackground,
                                          ),
                                        ),
                                        Text(
                                          ' ago',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8),
                              CupertinoButton(
                                padding: EdgeInsets.all(8),
                                borderRadius: BorderRadius.circular(10),
                                color: Theme.of(context).colorScheme.tertiary.withOpacity(0.4),
                                minSize: 0,
                                onPressed: () async {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  bool? isPremiumActivated =
                                      prefs.getBool('isPremiumActive');
                                  print(timingMeasurements.length);
                                  if (isPremiumActivated != true &&
                                      timingMeasurements.length > 400) {
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
                                child: Icon(
                                  CupertinoIcons.plus,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                              ),
                            ],
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
    );
  }
}
