import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chronolog/components/share_content/share_modal_frame.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/forms/edit_timepiece_form.dart';
import '../components/generic_alert.dart';
import '../components/timing_runs_container.dart';
import '../components/watch_details_stats.dart';
import '../models/timepiece.dart';
import '../providers/timepiece_list_provider.dart';

class WatchDetails extends ConsumerWidget {
  final Timepiece timepiece;
  bool firstAdded; // hack to show a dialog on first added watch

  WatchDetails({
    Key? key,
    required this.timepiece,
    this.firstAdded = false,
  }) : super(key: key);

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
                      Stack(children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: updatedTimepiece.image != null
                              ? Image.memory(
                                  updatedTimepiece.image!,
                                  fit: BoxFit.cover,
                                  height: 150,
                                )
                              : Image.asset(
                                  'assets/images/placeholder.png',
                                  fit: BoxFit.cover,
                                  height: 150,
                                ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: IconButton(
                            icon: Icon(Icons.zoom_in),
                            color: Colors.white,
                            onPressed: () {
                              _openFullSizeImage(
                                  context, updatedTimepiece.image);
                            },
                          ),
                        ),

                        // Icon at the bottom left
                        Positioned(
                          left: 0,
                          bottom: 0,
                          child: IconButton(
                            icon: Icon(Icons.upload),
                            color: Colors.white,
                            onPressed: () =>
                                showShareModal(context, updatedTimepiece),
                            // onPressed: () => Navigator.of(context).push(
                            //   MaterialPageRoute(
                            //     builder: (context) => ShareModalFrame(
                            //         timepiece: updatedTimepiece),
                            //   ),
                            // ),
                          ),
                        ),
                      ]),
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
                                  const SizedBox(width: 8),
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
                              SizedBox(height: 0),
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
            const SizedBox(height: 0),
            Divider(
              height: 4,
              thickness: 1,
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
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  CupertinoIcons.checkmark_circle,
                  size: 28,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              SizedBox(height: 12),
              Text(
                "You've added your first watch!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onBackground,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Now add your first measurement',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                  letterSpacing: -0.2,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'More time between measurements will yield more accurate results.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                  letterSpacing: -0.2,
                ),
              ),
              SizedBox(height: 16),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.of(context).pop(),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.tertiary,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.tertiary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openFullSizeImage(BuildContext context, Uint8List? imageBytes) {
    if (imageBytes == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () =>
                Navigator.of(context).pop(), // Optional: tap anywhere to close
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.memory(
                  imageBytes,
                  fit: BoxFit.contain,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: CircleAvatar(
                      radius: 14, // Size of close button
                      backgroundColor: Colors.black
                          .withOpacity(0.6), // Semi-transparent background
                      child: Icon(Icons.close, size: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

void showShareModal(BuildContext context, Timepiece timepiece) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      // Calculate 90% of the screen height
      final height = MediaQuery.of(context).size.height * 0.9;

      return Container(
        height: height,
        child: ShareModalFrame(timepiece: timepiece),
      );
    },
  );
}
