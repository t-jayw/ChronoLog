import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/forms/edit_timepiece_form.dart';
import '../components/generic_alert.dart';
import '../components/timing_runs_container.dart';
import '../components/watch_details_stats.dart';
import '../models/timepiece.dart';
import '../models/timing_measurement.dart';
import '../providers/timepiece_list_provider.dart';

class WatchDetails extends ConsumerWidget {
  final Timepiece timepiece;
  bool firstAdded; // hack to show a dialog on first added watch

  WatchDetails({
    Key? key,
    required this.timepiece,
    this.firstAdded = false,
  }) : super(key: key);

  String _formatDuration(Duration d) {
    String result = '';
    if (d.inDays > 0) {
      result = '${d.inDays} day${d.inDays != 1 ? 's' : ''} ago';
    } else if (d.inHours > 0) {
      result = '${d.inHours} hour${d.inHours != 1 ? 's' : ''} ago';
    } else if (d.inMinutes > 0) {
      result = '${d.inMinutes} minute${d.inMinutes != 1 ? 's' : ''} ago';
    } else {
      result = 'Just now';
    }
    return result;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timepieces = ref.watch(timepieceListProvider);

    final updatedTimepiece =
        timepieces.firstWhere((tp) => tp.id == timepiece.id);

    if (firstAdded) {
      // Note: We're using `firstAdded` field directly here.
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        _showFirstAddedDialog(context);
      });
      // this is to only show the first added dialog once
      firstAdded = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Watch Details",
            style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface)), // Use the updated name from the provider
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      EditTimepieceForm(timepiece: updatedTimepiece),
                ),
              );
            },
          ),
        ],
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: InkWell(
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => WatchDetails(timepiece: timepiece),
                  //   ),
                  // );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: updatedTimepiece.image != null
                            ? Image.memory(
                                updatedTimepiece.image!,
                                fit: BoxFit.cover,
                                height: 180,
                              )
                            : Image.asset(
                                'assets/images/placeholder.png',
                                fit: BoxFit.cover,
                                height: 180,
                              ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  AutoSizeText(
                                    updatedTimepiece.model,
                                    maxLines: 2,
                                    softWrap: true,
                                    overflow: TextOverflow.fade,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                  ),
                                  const SizedBox(width: 1),
                                  Expanded(
                                    child: AutoSizeText(
                                      updatedTimepiece.brand,
                                      maxLines: 1,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      minFontSize: 12,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 2),
                              WatchDetailStats(
                                timepiece: updatedTimepiece,
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Divider(
              thickness: 2,
            ),
            Expanded(
              child: TimingRunsContainer(timepiece: updatedTimepiece),
            ),
          ],
        ),
      ),
    );
  }

  void _showFirstAddedDialog(BuildContext context) {
    showGenericAlert(
      context: context,
      title: "You've added your first watch!",
      contentLines: [
        'Now add your first measurement',
        "",
        'More time between measurements will yield more accurate results.'
      ],
      cancelButtonText: 'OK',
    );
  }
}
