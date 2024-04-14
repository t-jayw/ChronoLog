import 'package:auto_size_text/auto_size_text.dart';
import 'package:chronolog/components/primary_button.dart';
import 'package:chronolog/components/share_content/share_content_modal.dart';
import 'package:flutter/material.dart';
import 'package:chronolog/models/timepiece.dart';

class ShareModalFrame extends StatelessWidget {
  final Timepiece timepiece;

  ShareModalFrame({Key? key, required this.timepiece}) : super(key: key);

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
              child: ShareModalContent(timepiece: timepiece),
            ),
            SizedBox(height: 8,),
            PrimaryButton(child: Text('Share', style: 
            TextStyle(color: Theme.of(context).colorScheme.inversePrimary)), onPressed: () {})
            
          ],
        ),
      ),
    );
  }
}