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
        borderRadius: BorderRadius.circular(20), // Increased for safety
        child: Container(
          padding: EdgeInsets.all(10), // Ensure padding to avoid clipping
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            border: Border.all(
              color: Colors.black,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(18), // Match with ClipRRect
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: imageProvider,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      spacing: 8,
                      runSpacing: 4,
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
                          style: TextStyle(fontSize: 20),
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
              SizedBox(height: 2),
              Expanded(child: ShareModalStats(timepiece: timepiece)),
              Divider(),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/wathclogo-40@2x.png',
                          width: 16),
                      SizedBox(width: 8),
                      Text(
                        "ChronoLog",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      Text(
                        " - Watch Accuracy",
                        style: TextStyle(
                          fontSize: 10,
                        ),
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
