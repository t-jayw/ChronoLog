import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chronolog/providers/timing_measurements_list_provider.dart';
import 'package:intl/intl.dart';

import '../data_helpers.dart/timing_run_parser.dart';
import '../models/timing_measurement.dart';
import '../models/timing_run.dart';
import 'measurement/measurement_selector_modal.dart';
import 'primary_button.dart'; // Assuming you have this file

class TimingRunDetailHeaderStats extends ConsumerStatefulWidget {
  const TimingRunDetailHeaderStats({
    super.key,
    required this.timingRun,
    this.isMostRecent,
  });

  final TimingRun timingRun;
  final bool? isMostRecent;

  @override
  _TimingRunDetailHeaderStatsState createState() => _TimingRunDetailHeaderStatsState();
}

class _TimingRunDetailHeaderStatsState extends ConsumerState<TimingRunDetailHeaderStats> {
  @override
  Widget build(BuildContext context) {
    final timingMeasurements = ref.watch(timingMeasurementsListProvider(widget.timingRun.id));
    TimingMeasurement? mostRecentMeasurement = timingMeasurements.isNotEmpty ? timingMeasurements.first : null;

    double? secondsPerDayForRun = mostRecentMeasurement != null ? calculateRatePerDay(timingMeasurements) : null;
    double? totalDurationDays = mostRecentMeasurement != null ? calculateTotalDuration(timingMeasurements) / 86400 : null; // 60 * 60 * 24
    String timeSinceLastMeasurement = mostRecentMeasurement != null ? _formatDuration(DateTime.now().difference(mostRecentMeasurement.system_time)) : "Just now";

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white, // Or any other color you want
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn(context, 'sec/day', '${secondsPerDayForRun?.toStringAsFixed(1) ?? "0"}', true),
              _buildStatColumn(context, 'Days', '${totalDurationDays?.toStringAsFixed(1) ?? "0"}', false),
              _buildStatColumn(context, 'Points', '${timingMeasurements.length}', false),
              _buildStatColumn(context, 'Last', timeSinceLastMeasurement, false),
            ],
          ),
          if (widget.isMostRecent ?? false) _buildAddMeasurementButton(context),
        ],
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String label, String value, bool highlight) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: highlight ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.onSurface,
            fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
      ],
    );
  }

  Widget _buildAddMeasurementButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: PrimaryButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) => DraggableScrollableSheet(
            expand: false,
            builder: (_, controller) => MeasurementSelectorModal(timingRunId: widget.timingRun.id),
          ),
        ),
        child: Text(
          'Add Measurement',
          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onPrimary),
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inDays > 0) {
      return '${d.inDays} day${d.inDays != 1 ? "s" : ""} ago';
    } else if (d.inHours > 0) {
      return '${d.inHours} hour${d.inHours != 1 ? "s" : ""} ago';
    } else if (d.inMinutes > 0) {
      return '${d.inMinutes} min${d.inMinutes != 1 ? "s" : ""} ago';
    } else {
      return 'Just now';
    }
  }
}
