import 'package:chronolog/components/primary_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ulid/ulid.dart';
import 'package:chronolog/components/timing_run_component.dart';

import '../models/timepiece.dart';
import '../models/timing_run.dart';
import '../providers/timing_run_provider.dart';
import 'custom_tool_tip.dart';
import 'delete_confirmation_dialog.dart';

class TimingRunsContainer extends ConsumerWidget {
  const TimingRunsContainer({Key? key, required this.timepiece})
      : super(key: key);

  final Timepiece timepiece;

  void _addTimingRun(WidgetRef ref) {
    final Ulid ulid = Ulid();

    final timingRunId = ulid.toString();
    final startTime = DateTime.now();
    final timingRun = TimingRun(
      id: timingRunId,
      watch_id: timepiece.id,
      startDate: startTime,
    );
    ref.read(timingRunProvider(timepiece.id).notifier).addTimingRun(timingRun);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timingRuns = ref.watch(timingRunProvider(timepiece.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomToolTip(
          mainAxisAlignment: MainAxisAlignment.center,
          child: Text(
            "Start a new timing run after setting your watch",
            style: TextStyle(fontSize: 12.0), // you can style your text here
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: SizedBox(
            child: SecondaryButton(
              text: 'Start Timing Run',
              onPressed: () => _addTimingRun(ref),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: timingRuns.length,
            itemBuilder: (context, index) {
              final timingRun = timingRuns[index];

              final isMostRecentTimingRun = index == 0;

              return Dismissible(
                key: Key(timingRun.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  return await showCupertinoDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return DeleteConfirmationDialog();
                    },
                  );
                },
                onDismissed: (direction) {
                  ref
                      .read(timingRunProvider(timepiece.id).notifier)
                      .deleteTimingRun(timingRun.id);
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(Icons.delete,
                      color: Theme.of(context).colorScheme.error, size: 40),
                ),
                child: TimingRunComponent(
                    timingRun: timingRun,
                    timepiece: timepiece,
                    isMostRecent: isMostRecentTimingRun),
              );
            },
          ),
        ),
      ],
    );
  }
}
