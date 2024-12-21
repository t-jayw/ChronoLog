import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chronolog/providers/timing_measurements_list_provider.dart';

import '../data_helpers.dart/timing_run_parser.dart';
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
    final stats = TimingRunStatistics(timingMeasurements);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatColumn(context, 'SEC/DAY', stats.formattedSecondsPerDayForRun()),
              _buildStatColumn(context, 'DURATION', stats.formattedTotalDuration()),
              _buildStatColumn(context, 'POINTS', stats.totalPoints.toString()),
              _buildStatColumn(context, 'LAST', stats.formattedTimeSinceLastMeasurement()),
            ],
          ),
          if (widget.isMostRecent ?? false) 
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SizedBox(
                width: double.infinity,
                height: 40,
                child: PrimaryButton(
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => DraggableScrollableSheet(
                      expand: false,
                      builder: (_, controller) => MeasurementSelectorModal(timingRunId: widget.timingRun.id),
                    ),
                  ),
                  child: Text('Add Measurement',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
          style: TextStyle(
            fontSize: 15,
            color: Theme.of(context).colorScheme.tertiary,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(label,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ],
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
