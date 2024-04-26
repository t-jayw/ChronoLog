import 'package:chronolog/components/custom_tool_tip.dart';
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
        final directory = await getTemporaryDirectory();
        File imgFile = File('${directory.path}/share.png');
        await imgFile.writeAsBytes(pngBytes);
        Share.shareFiles([imgFile.path], text: 'Check out my watch accuracy!');
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
        title: Text('Share Preview'),
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),

      //repaintBoundaryKey: repaintBoundaryKey
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              CustomToolTip(
                  child: Text(
                    "Sharing the active Timing Run",
                    style: TextStyle(
                        fontSize: 10.0), // you can style your text here
                  ),
                  mainAxisAlignment: MainAxisAlignment.center),
              SizedBox(height: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: ShareModalContent(
                      timepiece: timepiece,
                      repaintBoundaryKey: repaintBoundaryKey),
                ),
              ),
              SizedBox(height: 16),
              PrimaryButton(
                child: Text('Share',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary)),
                onPressed: shareContent,
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
