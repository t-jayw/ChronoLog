import 'package:auto_size_text/auto_size_text.dart';
import 'package:chronolog/components/share_content/share_content_stats.dart';
import 'package:flutter/material.dart';
import 'package:chronolog/models/timepiece.dart';
import 'package:flutter/widgets.dart';

class ShareModalContent extends StatelessWidget {
  final Timepiece timepiece;

  ShareModalContent({Key? key, required this.timepiece}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ImageProvider imageProvider;
    if (timepiece.image != null && timepiece.image!.isNotEmpty) {
      imageProvider = MemoryImage(timepiece.image!);
    } else {
      imageProvider = AssetImage('assets/images/placeholder.png');
    }

    return Container(
      padding: EdgeInsets.all(16),
      width: double.infinity, // Full width for better layout and sizing
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.black, // Black color border
          width: 2, // Width of the border
        ),
      ),
      child: Column(
        //mainAxisSize: MainAxisSize.min,
        children: [
          // Top row with the image, timepiece brand, and name
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CircleAvatar(
                radius: 40, // Adjust the size as needed
                backgroundImage: imageProvider,
              ),
              SizedBox(width: 16), // Spacing between image and text

              Column(
                children: [
                  AutoSizeText(
                    timepiece.brand,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 4),
                  AutoSizeText(
                    timepiece.model,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              Expanded(child: ShareModalStats(timepiece: timepiece)),
            ],
          ),
          SizedBox(height: 8), // Spacing between the top row and stats
          // Stats
          ShareModalStats(timepiece: timepiece),

          Divider(),
          // Footer with branding
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "ChronoLog Watch Accuracy on iOS",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
