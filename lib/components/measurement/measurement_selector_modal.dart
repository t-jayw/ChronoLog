import 'package:chronolog/components/custom_tool_tip.dart';
import 'package:chronolog/components/primary_button.dart';
import 'package:chronolog/measurement_forms/add_measurement_button_page.dart';
import 'package:chronolog/measurement_forms/add_measurement_photo_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

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
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Divider(),
            SizedBox(height: 20),
            measurementOption(context, Icons.photo_camera, 'Photo', () async {
              Posthog().capture(
                  eventName: 'measurement_selected',
                  properties: {'method': 'photo'});
              Navigator.of(context).pop();
              await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) =>
                      AddMeasurementPhoto(timingRunId: timingRunId)));
            }),
            SizedBox(height: 10), // Added space for visual separation
            CustomToolTip(
              mainAxisAlignment: MainAxisAlignment.center,
              child: Text(
                "Take a photo and enter the time",
                style: TextStyle(fontSize: 12.0),
              ),
            ),
            SizedBox(height: 20), // Divider or extra space
            measurementOption(context, Icons.touch_app, 'Tap', () async {
              Posthog().capture(
                  eventName: 'measurement_selected',
                  properties: {'method': 'tap'});
              Navigator.of(context).pop();
              await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) =>
                      AddMeasurementButtonPage(timingRunId: timingRunId)));
            }),
            SizedBox(height: 10), // Added space for visual separation
            CustomToolTip(
              mainAxisAlignment: MainAxisAlignment.center,
              child: Text(
                "Tap a button at specific time",
                style: TextStyle(fontSize: 12.0),
              ),
            ),
            SizedBox(height: 20),
            SecondaryButton(
              text:
                "Close"
               ,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget measurementOption(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return PrimaryButton(
      onPressed: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: Theme.of(context).colorScheme.onInverseSurface,
          ), // Icon for the button
          SizedBox(width: 8), // Space between icon and text
          Text(title,
              style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context)
                      .colorScheme
                      .onInverseSurface)), // Text label
        ],
      ),
    );
  }
}
