import 'package:auto_size_text/auto_size_text.dart';
import 'package:chronolog/components/share_content/share_content_stats.dart';
import 'package:flutter/material.dart';
import 'package:chronolog/models/timepiece.dart';

class ShareModalContent extends StatelessWidget {
  final Timepiece timepiece;
  final GlobalKey repaintBoundaryKey;

  ShareModalContent(
      {Key? key, required this.timepiece, required this.repaintBoundaryKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ImageProvider imageProvider;
    if (timepiece.image != null && timepiece.image!.isNotEmpty) {
      imageProvider = MemoryImage(timepiece.image!);
    } else {
      imageProvider = AssetImage('assets/images/placeholder.png');
    }

    return RepaintBoundary(
      key: repaintBoundaryKey,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          // Ensuring the background color is not transparent

          padding: EdgeInsets.all(8),
          height: MediaQuery.of(context).size.height * 0.4,
          width: MediaQuery.of(context)
              .size
              .width, // Full width for better layout and sizing
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).canvasColor,
            border: Border.all(
              color: Colors.black, // Black color border
              width: 2, // Width of the border
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30, // Adjust the size as needed
                    backgroundImage: imageProvider,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      spacing:
                          8, // space between brand and model if on the same line
                      runSpacing: 4, // space between lines
                      children: [
                        AutoSizeText(
                          timepiece.brand,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        AutoSizeText(
                          timepiece.model,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        Divider(
                          height: 0,
                          thickness: 1,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2), // Spacing between the top row and stats
              Expanded(child: ShareModalStats(timepiece: timepiece)),

              Divider(),
              // Footer with branding
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    //mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/images/wathclogo-40@2x.png',
                          width: 20), // Your app icon
                      SizedBox(width: 8),
                      Row(
                        children: [
                          Text(
                            "ChronoLog",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
Text(
                            " - Watch Accuracy",
                            style: TextStyle(
                              fontSize: 12,

                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                          
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
