import 'package:chronolog/components/measurement/measurement_selector_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chronolog/providers/timing_measurements_list_provider.dart';
import 'package:intl/intl.dart';

import '../data_helpers.dart/timing_run_parser.dart';
import '../models/timepiece.dart';
import '../models/timing_measurement.dart';
import '../models/timing_run.dart';
import '../screens/timing_run_details_screen.dart';
import 'primary_button.dart';

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

  String _formatDuration(Duration d) {
    if (d.inDays > 0) return '${d.inDays} day${d.inDays != 1 ? 's' : ''} ago';
    if (d.inHours > 0)
      return '${d.inHours} hour${d.inHours != 1 ? 's' : ''} ago';
    if (d.inMinutes > 0)
      return '${d.inMinutes} minute${d.inMinutes != 1 ? 's' : ''} ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    final timingMeasurements =
        ref.watch(timingMeasurementsListProvider(widget.timingRun.id));
    final TimingMeasurement? mostRecentMeasurement =
        timingMeasurements.isNotEmpty ? timingMeasurements.first : null;

    final double? secondsPerDayForRun = mostRecentMeasurement != null
        ? calculateRatePerDay(timingMeasurements)
        : null;
    final double? totalDurationDays = mostRecentMeasurement != null
        ? calculateTotalDuration(timingMeasurements) / 60 / 60 / 24
        : null;
    final String timeSinceLastMeasurement = mostRecentMeasurement != null
        ? _formatDuration(
            DateTime.now().difference(mostRecentMeasurement.system_time))
        : '';

    return InkWell(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TimingRunDetails(
                  timingRun: widget.timingRun, timepiece: widget.timepiece))),
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 2.0, horizontal: 12.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Timing Run', style: TextStyle(fontSize: 12)),
                    Icon(Icons.chevron_right)
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
                        Text(
                            '${secondsPerDayForRun?.toStringAsFixed(1) ?? "0"}',
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
                        Text(
                            '${totalDurationDays?.toStringAsFixed(1) ?? "0"} days',
                            style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.tertiary,
                                fontWeight: FontWeight.bold)),
                        Text('${timingMeasurements.length} points',
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                                fontSize: 12)),
                        Text(timeSinceLastMeasurement,
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                                fontSize: 12)),
                      ],
                    ),
                    if (widget.isMostRecent ?? false)
                      PrimaryButton(
                        onPressed: () 
                         async {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled:
                          true, // Set to true to make the bottom sheet full-screen
                      builder: (BuildContext context) {
                        // You can return the ManageSettingsScreen or a widget that is more suited for a modal layout
                        return DraggableScrollableSheet(
                          expand: false,
                          builder: (_, controller) => SingleChildScrollView(
                            controller: controller,
                            child:
                                MeasurementSelectorModal(timingRunId: widget.timingRun.id,), // Ensure your ManageSettingsScreen is suitable for this context
                          ),
                        );
                      },
                    );
                  },
                        
                       
                        child: Text('➕Measurement',
                            style: TextStyle(
                                fontSize: 12,
                                color:
                                    Theme.of(context).colorScheme.onPrimary)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
