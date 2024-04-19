import 'package:chronolog/components/primary_button.dart';
import 'package:chronolog/components/share_content/share_modal_content.dart';
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

        // Saving the file locally to temp directory
        final directory = await getTemporaryDirectory();
        File imgFile = File('${directory.path}/share.png');
        await imgFile.writeAsBytes(pngBytes);

        // Sharing the file
        Share.shareFiles([imgFile.path], text: 'Check out my watch accuracy!');
      } else {
        // Handle the case where byte data could not be obtained
        debugPrint('Failed to obtain byte data from the image');
      }
    } else {
      // Handle the case where the repaint boundary is not available
      debugPrint('Repaint boundary was not available');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Share Preview'),
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Container(
              child: ShareModalContent(
                  timepiece: timepiece, repaintBoundaryKey: repaintBoundaryKey),
            ),
            SizedBox(height: 8),
            PrimaryButton(
              child: Text('Share',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary)),
              onPressed: shareContent,
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
