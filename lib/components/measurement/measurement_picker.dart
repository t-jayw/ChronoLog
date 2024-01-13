import 'package:chronolog/components/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import '../../measurement_forms/add_measurement_button_page.dart';
import '../../measurement_forms/add_measurement_photo_page.dart';
import '../custom_tool_tip.dart';

class MeasurementPicker extends StatelessWidget {
  final String timingRunId;

  MeasurementPicker({Key? key, required this.timingRunId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Posthog().screen(
      screenName: 'measurement_picker',
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      height:
          MediaQuery.of(context).size.height / 3, // Half of the screen height
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('Choose How to Measure'),
              // CustomToolTip(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   child: Flexible(
              //     child: Text(
              //       "Choose an option to measure",
              //       style: TextStyle(
              //           fontSize: 12.0), // you can style your text here
              //     ),
              //   ),
              // ),
              
              Divider(),
              Expanded(
                child: Column(
                  children: [
                    buildButton(context, Icons.photo_camera, "Photo",
                        () async {
                      Posthog().capture(
                        eventName: 'measurement_selected',
                        properties: {
                          'method': 'photo',
                        },
                      );

                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              AddMeasurementPhoto(timingRunId: timingRunId),
                        ),
                      );
                      Navigator.of(context).pop();
                    }),
                    CustomToolTip(
                      mainAxisAlignment: MainAxisAlignment.center,
                      child: Flexible(
                        child: Text(
                          "Take a photo and enter the time",
                          style: TextStyle(
                              fontSize: 12.0), // you can style your text here
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              Expanded(
                child: Column(
                  children: [
                    buildButton(context, Icons.touch_app, "Tap",
                        () async {
                      Posthog().capture(
                        eventName: 'measurement_selected',
                        properties: {
                          'method': 'tap',
                        },
                      );
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              AddMeasurementButtonPage(timingRunId: timingRunId),
                        ),
                      );
                      Navigator.of(context).pop();
                    }),
                                        CustomToolTip(
                      mainAxisAlignment: MainAxisAlignment.center,
                      child: Flexible(
                        child: Text(
                          "Tap a button at specific time",
                          style: TextStyle(
                              fontSize: 12.0), // you can style your text here
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildButton(BuildContext context, IconData icon, String title,
      VoidCallback onPressed) {
    return Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            Icon(icon, size: 44),
            VerticalDivider(),
            Expanded(
              child: PrimaryButton(
                  child: Text(
                    title,
                    style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  onPressed: onPressed),
            ),
          ],
        ));
  }
}
