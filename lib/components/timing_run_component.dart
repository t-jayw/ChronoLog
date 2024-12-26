import 'package:chronolog/components/measurement/measurement_selector_modal.dart';
import 'package:chronolog/components/premium/premium_needed_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chronolog/providers/timing_measurements_list_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';

import '../data_helpers.dart/timing_run_parser.dart';
import '../models/timepiece.dart';
import '../models/timing_run.dart';
import '../screens/timing_run_details_screen.dart';

class TimingRunComponent extends ConsumerStatefulWidget {
  final TimingRun timingRun;
  final Timepiece timepiece;
  final bool? isMostRecent;
  final bool navigation;

  const TimingRunComponent({
    super.key,
    required this.timingRun,
    required this.timepiece,
    this.isMostRecent,
    this.navigation = true,
  });

  @override
  _TimingRunComponentState createState() => _TimingRunComponentState();
}

class _TimingRunComponentState extends ConsumerState<TimingRunComponent> {
  bool showTimingMeasurements = false;

  @override
  Widget build(BuildContext context) {
    final timingMeasurements =
        ref.watch(timingMeasurementsListProvider(widget.timingRun.id));

    TimingRunStatistics timingRunStats =
        TimingRunStatistics(timingMeasurements);

    Widget contentWidget = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Timing Run',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    Text(
                      "total duration: ${timingRunStats.formattedTotalDuration() ?? '-'}",
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.navigation)
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            timingRunStats.formattedLatestOffset(),
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          Text(
                            'offset',
                            style: TextStyle(
                              fontSize: 8,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            timingRunStats.formattedSecondsPerDayForRun(),
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          Text(
                            'sec/day',
                            style: TextStyle(
                              fontSize: 8,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.isMostRecent ?? false)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              timingRunStats.formattedTimeSinceLastMeasurement(),
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            Text(
                              'since last',
                              style: TextStyle(
                                fontSize: 8,
                                color: Theme.of(context).colorScheme.onBackground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '${timingMeasurements.length}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                          Text(
                            'measurements',
                            style: TextStyle(
                              fontSize: 8,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Commented out plus button for new measurements
              // if (widget.isMostRecent ?? false)
              //   CupertinoButton(
              //     padding: EdgeInsets.all(6),
              //     borderRadius: BorderRadius.circular(10),
              //     color: Colors.transparent,
              //     minSize: 0,
              //     onPressed: () async {
              //       SharedPreferences prefs =
              //           await SharedPreferences.getInstance();
              //       bool? isPremiumActivated =
              //           prefs.getBool('in_app_premiumActive');

              //       if (isPremiumActivated != true &&
              //           timingMeasurements.length > 400) {
              //         showPremiumNeededDialog(context,
              //             "Free version limited to 5 measurements per Timing Run");
              //       } else {
              //         showModalBottomSheet(
              //           context: context,
              //           isScrollControlled: true,
              //           builder: (BuildContext context) {
              //             return DraggableScrollableSheet(
              //               expand: false,
              //               builder: (_, controller) =>
              //                   SingleChildScrollView(
              //                 controller: controller,
              //                 child: MeasurementSelectorModal(
              //                   timingRunId: widget.timingRun.id,
              //                 ),
              //               ),
              //             );
              //           },
              //         );
              //       }
              //     },
              //     child: Container(
              //       decoration: BoxDecoration(
              //         border: Border.all(
              //           color: Theme.of(context).colorScheme.tertiary,
              //           width: 2,
              //         ),
              //         borderRadius: BorderRadius.circular(10),
              //       ),
              //       child: Icon(
              //         CupertinoIcons.plus,
              //         size: 20,
              //         color: Theme.of(context).colorScheme.tertiary,
              //       ),
              //     ),
              //   ),
            ],
          ),
          if (timingMeasurements.length >= 2)
            widget.isMostRecent ?? false
                ? Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: timingRunStats.checkCompliance().map((standard) =>
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.secondary,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  standard,
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: Theme.of(context).colorScheme.tertiary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ).toList(),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.tertiary,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () async {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              bool? isPremiumActivated = prefs.getBool('in_app_premiumActive');

                              if (isPremiumActivated != true && timingMeasurements.length > 400) {
                                showPremiumNeededDialog(context,
                                    "Free version limited to 5 measurements per Timing Run");
                              } else {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (BuildContext context) {
                                    return DraggableScrollableSheet(
                                      expand: false,
                                      builder: (_, controller) => SingleChildScrollView(
                                        controller: controller,
                                        child: MeasurementSelectorModal(
                                          timingRunId: widget.timingRun.id,
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
                                  size: 12,
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Take Measurement',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).colorScheme.tertiary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ...timingRunStats.checkCompliance().map((standard) => 
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                standard,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(context).colorScheme.tertiary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ).toList(),
                      ],
                    ),
                  ),
        ],
      ),
    );

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
      child: widget.navigation
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => TimingRunDetails(
                    timingRun: widget.timingRun,
                    timepiece: widget.timepiece,
                  ),
                ),
              ),
              child: contentWidget,
            )
          : contentWidget,
    );
  }
}
