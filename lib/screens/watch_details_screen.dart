import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chronolog/components/share_content/share_modal_frame.dart';
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
                                  height: 160,
                                )
                              : Image.asset(
                                  'assets/images/placeholder.png',
                                  fit: BoxFit.cover,
                                  height: 160,
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
    isScrollControlled: true, // Allows the modal to take up full screen height
    builder: (BuildContext context) {
      // Calculate three-quarters of the screen height
//      final height = MediaQuery.of(context).size.height * 0.66;
      final height = 525.0;

      return Container(
        height: height, // Use the calculated height here
        child: ShareModalFrame(timepiece: timepiece),
      );
    },
  );
}
