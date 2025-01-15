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
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.graph_square,
                          size: 13,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Timing Run',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "total duration: ${timingRunStats.formattedTotalDuration()}",
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.navigation)
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
            padding: const EdgeInsets.symmetric(vertical: 10.0),
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
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.tertiary,
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
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.tertiary,
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
                              timingRunStats
                                  .formattedTimeSinceLastMeasurement(),
                              style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                          Text(
                            'last',
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
                              fontSize: 15,
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
            ],
          ),
          if (widget.isMostRecent ?? false)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(child: _buildComplianceBadges()),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CupertinoButton(
                      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                      minSize: 0,
                      onPressed: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        bool? isPremiumActivated =
                            prefs.getBool('premiumActive');

                        if (isPremiumActivated != true &&
                            timingMeasurements.length > 4) {
                          showPremiumNeededDialog(
                              context,
                              "Free version limited to 5 measurements per Timing Run",
                              "num_measurements_paywall"
                          );
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
                            'Add Measurement',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.tertiary,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: _buildComplianceBadges(),
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

  Widget _buildComplianceBadges() {
    final timingMeasurements =
        ref.watch(timingMeasurementsListProvider(widget.timingRun.id));
    final timingRunStats = TimingRunStatistics(timingMeasurements);

    final complianceStandards = timingRunStats.checkCompliance();

    // Return empty container if no compliance standards
    if (complianceStandards.isEmpty) {
      return Container();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: complianceStandards
          .map(
            (standard) => Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 1,
                  ),
                ),
                child: Text(
                  standard,
                  style: TextStyle(
                    fontSize: 9,
                    color: Theme.of(context).colorScheme.onBackground,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
