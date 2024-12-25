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

  const TimingRunComponent({
    super.key,
    required this.timingRun,
    required this.timepiece,
    this.isMostRecent,
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

    List<Widget> certificationWidgets = [];
    List<String> complianceStatuses = timingRunStats.checkCompliance();
    for (var status in complianceStatuses) {
      certificationWidgets.add(
        Row(
          children: [
            SizedBox(width: 4),
            Icon(
              CupertinoIcons.checkmark_circle_fill,
              color: Colors.green,
              size: 12,
            ),
            SizedBox(width: 4),
            Text(status, 
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400
              )
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => TimingRunDetails(
                  timingRun: widget.timingRun, timepiece: widget.timepiece))),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Timing Run', 
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500
                    )
                  ),
                  Icon(CupertinoIcons.chevron_right, size: 16)
                ],
              ),
              Divider(
                height: 4,
                thickness: 1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(timingRunStats.formattedSecondsPerDayForRun(),
                          style: TextStyle(
                              fontSize: 24,
                              color: Theme.of(context).colorScheme.tertiary,
                              fontWeight: FontWeight.bold)),
                      Text('sec/day',
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onBackground)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Text(timingRunStats.formattedTotalDuration(),
                              style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      Theme.of(context).colorScheme.tertiary,
                                  fontWeight: FontWeight.bold)),
                          Text(' duration',
                              style: TextStyle(
                                fontSize: 10,
                              )),
                        ],
                      ),
                      Row(
                        children: [
                          Text('${timingMeasurements.length}',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  fontSize: 12)),
                          Text(' points',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  fontSize: 10)),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                              timingRunStats
                                  .formattedTimeSinceLastMeasurement(),
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  fontSize: 12)),
                          Text(' ago',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                  if (certificationWidgets.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: certificationWidgets,
                    ),
                  if (widget.isMostRecent ?? false)
                    CupertinoButton(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      color: Theme.of(context).colorScheme.tertiary,
                      borderRadius: BorderRadius.circular(8),
                      minSize: 0,
                      onPressed: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        bool? isPremiumActivated =
                            prefs.getBool('isPremiumActive');

                        if (isPremiumActivated != true &&
                            timingMeasurements.length > 400) {
                          showPremiumNeededDialog(context,
                              "Free version limited to 5 measurements per Timing Run");
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
                                    timingRunId: widget.timingRun.id,
                                  ), // Ensure your ManageSettingsScreen is suitable for this context
                                ),
                              );
                            },
                          );
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CupertinoIcons.add,
                              size: 18,
                              color: Theme.of(context).colorScheme.onPrimary),
                          SizedBox(width: 4),
                          Text(
                            'Add',
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
