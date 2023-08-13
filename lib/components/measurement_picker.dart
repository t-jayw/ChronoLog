import 'package:chronolog/components/primary_button.dart';
import 'package:flutter/material.dart';

import '../measurement_forms/add_measurement_button_page.dart';
import '../measurement_forms/add_measurement_photo_page.dart';
import 'custom_tool_tip.dart';

class MeasurementPicker extends StatelessWidget {
  final String timingRunId;

  MeasurementPicker({Key? key, required this.timingRunId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      height:
          MediaQuery.of(context).size.height / 5, // Half of the screen height
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomToolTip(
                mainAxisAlignment: MainAxisAlignment.center,
                child: Flexible(
                  child: Text(
                    "Choose how to enter your watch's time.",
                    style: TextStyle(
                        fontSize: 12.0), // you can style your text here
                  ),
                ),
              ),
              Divider(),
              Expanded(
                child: buildButton(
                    context, Icons.photo_camera, "Measure with Pic", () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          AddMeasurementPhoto(timingRunId: timingRunId),
                    ),
                  );
                  Navigator.of(context).pop();
                }),
              ),
              Divider(),
              Expanded(
                child: buildButton(context, Icons.touch_app, "Measure with Tap",
                    () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          AddMeasurementButtonPage(timingRunId: timingRunId),
                    ),
                  );
                  Navigator.of(context).pop();
                }),
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
