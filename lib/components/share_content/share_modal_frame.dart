import 'package:chronolog/components/custom_tool_tip.dart';
import 'package:chronolog/components/primary_button.dart';
import 'package:chronolog/components/share_content/share_modal_content.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chronolog/models/timepiece.dart';

import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ShareModalFrame extends StatelessWidget {
  final Timepiece timepiece;
  final GlobalKey repaintBoundaryKey = GlobalKey();

  ShareModalFrame({Key? key, required this.timepiece}) : super(key: key);

  Future<void> shareContent() async {
    RenderRepaintBoundary? boundary = repaintBoundaryKey.currentContext
        ?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary != null) {
      ui.Image image = await boundary.toImage(pixelRatio: 5.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();
        final directory = await getTemporaryDirectory();
        File imgFile = File('${directory.path}/share.png');
        await imgFile.writeAsBytes(pngBytes);
        Share.shareFiles([imgFile.path]);
      } else {
        debugPrint('Failed to obtain byte data from the image');
      }
    } else {
      debugPrint('Repaint boundary was not available');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Share Preview',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          CupertinoButton(
            padding: EdgeInsets.all(4),
            child: Icon(
              CupertinoIcons.xmark,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            CustomToolTip(
              child: Text(
                "Active Timing Run",
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                ),
              ),
              mainAxisAlignment: MainAxisAlignment.center,
            ),
            SizedBox(height: 4),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: ShareModalContent(
                  timepiece: timepiece,
                  repaintBoundaryKey: repaintBoundaryKey,
                ),
              ),
            ),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              child: CupertinoButton(
                padding: EdgeInsets.symmetric(vertical: 4),
                color: Theme.of(context).colorScheme.tertiary,
                borderRadius: BorderRadius.circular(12),
                onPressed: shareContent,
                child: Text(
                  'Share',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}
