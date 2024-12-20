import 'package:chronolog/components/custom_tool_tip.dart';
import 'package:chronolog/components/primary_button.dart';
import 'package:chronolog/measurement_forms/add_measurement_button_page.dart';
import 'package:chronolog/measurement_forms/add_measurement_photo_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:flutter/cupertino.dart';

class MeasurementSelectorModal extends ConsumerWidget {
  final String timingRunId;

  MeasurementSelectorModal({Key? key, required this.timingRunId})
      : super(key: key);

      

  @override
  Widget build(BuildContext context, WidgetRef ref) {


    
    return Container(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Choose How to Measure',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.label.resolveFrom(context),
              ),
            ),
            Divider(),
            SizedBox(height: 20),
            CupertinoButton(
              padding: EdgeInsets.symmetric(vertical: 8),
              color: CupertinoTheme.of(context).primaryColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.hand_point_right, size: 20, color: CupertinoColors.white),
                  SizedBox(width: 8),
                  Text('Tap',
                      style: TextStyle(color: CupertinoColors.white, fontSize: 14)),
                ],
              ),
              onPressed: () async {
                Posthog().capture(
                    eventName: 'measurement_selected',
                    properties: {'method': 'tap'});
                Navigator.of(context).pop();
                await Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        AddMeasurementButtonPage(timingRunId: timingRunId)));
              },
            ),
            SizedBox(height: 10),
            Text(
              "Tap a button at specific time",
              style: TextStyle(
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
                fontSize: 12,
              ),
            ),
            SizedBox(height: 20),
            CupertinoButton(
              padding: EdgeInsets.symmetric(vertical: 8),
              color: CupertinoTheme.of(context).primaryColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.camera, size: 20, color: CupertinoColors.white),
                  SizedBox(width: 8),
                  Text('Photo',
                      style: TextStyle(color: CupertinoColors.white, fontSize: 14)),
                ],
              ),
              onPressed: () async {
                Posthog().capture(
                    eventName: 'measurement_selected',
                    properties: {'method': 'photo'});
                Navigator.of(context).pop();
                await Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => AddMeasurementPhoto(timingRunId: timingRunId)));
              },
            ),
            SizedBox(height: 10),
            Text(
              "Take a photo and enter the time",
              style: TextStyle(
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
                fontSize: 12,
              ),
            ),
            SizedBox(height: 20),
            CupertinoButton(
              child: Text('Close',
                style: TextStyle(
                color: CupertinoColors.label.resolveFrom(context),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
