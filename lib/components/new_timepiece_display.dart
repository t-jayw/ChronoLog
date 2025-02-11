import 'package:chronolog/components/measurement/measurement_selector_modal.dart';
import 'package:chronolog/components/premium/premium_needed_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    ref.listen(
        StreamProvider((ref) => Stream.periodic(const Duration(minutes: 1))),
        (_, __) {});

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
      width: double.infinity,
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
          padding: const EdgeInsets.all(7.0),
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
                      : SvgPicture.asset(
                          'assets/images/watch_placeholder.svg',
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).colorScheme.onSurface,
                            BlendMode.srcIn,
                          ),
                        ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      timepiece.brand,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground
                                            .withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                CupertinoIcons.chevron_right,
                                size: 20,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onBackground
                                    .withOpacity(0.3),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Divider(
                              height: 1,
                              thickness: 0.5,
                              color: CupertinoColors.separator
                                  .resolveFrom(context),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Active Timing Run',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground
                                      .withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            timingRunStats
                                                    .formattedLatestOffset() ??
                                                '-',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .tertiary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            'offset',
                                            style: TextStyle(
                                              fontSize: 9,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            timingRunStats
                                                .formattedSecondsPerDayForRun(),
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .tertiary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            'sec/day',
                                            style: TextStyle(
                                              fontSize: 9,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            timingRunStats
                                                    .formattedTimeSinceLastMeasurement() ??
                                                '-',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .tertiary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                          ),
                                          Container(
                                            width: double.infinity,
                                            height: 11,
                                            child: Text(
                                              'last',
                                              style: TextStyle(
                                                fontSize: 9,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onBackground,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 3, vertical: 0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: CupertinoButton(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 2, vertical: 3),
                                  minSize: 0,
                                  onPressed: () async {
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    bool? isPremiumActivated =
                                        prefs.getBool('premiumActive');

                                    if (isPremiumActivated != true &&
                                        timingMeasurements.length > 5) {
                                      showPremiumNeededDialog(context,
                                          "Free version limited to 5 measurements per Timing Run");
                                    } else {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (BuildContext context) {
                                          return DraggableScrollableSheet(
                                            expand: false,
                                            builder: (_, controller) =>
                                                SingleChildScrollView(
                                              controller: controller,
                                              child: MeasurementSelectorModal(
                                                timingRunId:
                                                    mostRecentRun?.id ?? '',
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        CupertinoIcons.plus,
                                        size: 14,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiary,
                                      ),
                                      SizedBox(width: 2),
                                      Text(
                                        'Add Measurement',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiary,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                    ],
                                  ),
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
