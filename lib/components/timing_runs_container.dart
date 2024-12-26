import 'package:chronolog/components/custom_tool_tip.dart';
import 'package:chronolog/components/premium/premium_needed_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ulid/ulid.dart';
import 'package:chronolog/components/timing_run_component.dart';

import '../models/timepiece.dart';
import '../models/timing_run.dart';
import '../providers/timing_run_provider.dart';
import 'ads/footer_banner_ad.dart';
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
      watchId: timepiece.id,
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: CustomToolTip(
                  child: Text(
                    "Start a new timing run when you set the watch",
                    style: TextStyle(
                      fontSize: 10.0,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  mainAxisAlignment: MainAxisAlignment.start,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.all(4),
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.tertiary.withOpacity(0.8),
                minSize: 0,
                onPressed: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  bool? isPremiumActivated = prefs.getBool('is_premium_active');
                  int numTimingRuns = timingRuns.length;

                  if (isPremiumActivated != true && numTimingRuns == 2) {
                    Posthog().capture(
                      eventName: 'paywall',
                      properties: {
                        'reason': 'num_timing_runs_paywall',
                      },
                    );
                    showPremiumNeededDialog(context,
                        "Free version limited to 2 Timing Runs per timepiece");
                  } else {
                    _addTimingRun(ref);
                  }
                },
                child: Icon(
                  CupertinoIcons.plus,
                  size: 16,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
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
                  if (timingRuns.length <= 1) {
                    // Show the SnackBar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Center(
                            child: Text("Can't delete the only timing run!")),
                        duration: Duration(seconds: 3),
                      ),
                    );
                    return false; // Do not allow dismissal if it's the only remaining timing run
                  }

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
                  padding: const EdgeInsets.only(right: 4.0),
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
        FooterBannerAdWidget(),
      ],
    );
  }
}
