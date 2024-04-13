import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:chronolog/models/timepiece.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'watch_details_stats.dart';  // Ensure this is the correct path to the widget

class WatchDetailShareContent extends StatelessWidget {
  final Timepiece timepiece;
  final GlobalKey repaintBoundaryKey = GlobalKey();

  WatchDetailShareContent({Key? key, required this.timepiece}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: repaintBoundaryKey,
      child: Container(
        width: 400, // Define a fixed width suitable for social media sharing
        height: 300, // Set a fixed height to control the layout more effectively
        padding: EdgeInsets.all(10), // Add padding around the content
        color: Colors.white, // Ensure background color is suitable for readability
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space out elements vertically
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 120, // Smaller width for the image
                    height: 120, // Smaller height for the image
                    child: timepiece.image != null
                        ? Image.memory(timepiece.image!, fit: BoxFit.cover)
                        : Image.asset('assets/images/placeholder.png', fit: BoxFit.cover),
                  ),
                ),
                SizedBox(width: 10), // Space between image and text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        timepiece.model,
                        maxLines: 1, // Ensure text does not overflow
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      AutoSizeText(
                        timepiece.brand,
                        maxLines: 1, // Ensure text does not overflow
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            WatchDetailStats(timepiece: timepiece), // Ensure this widget fits within the layout
            Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                "ChronoLog Watch Accuracy on iOS",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

