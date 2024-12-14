import 'package:chronolog/components/measurement/configurable_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ulid/ulid.dart';
import '../components/measurement/tag_selector.dart';

import '../components/primary_button.dart';
import '../models/timing_measurement.dart';
import '../providers/timing_measurements_list_provider.dart';

class AddMeasurementButtonPage extends StatefulWidget {
  const AddMeasurementButtonPage({Key? key, required this.timingRunId})
      : super(key: key);

  final String timingRunId;

  @override
  _AddMeasurementButtonPageState createState() =>
      _AddMeasurementButtonPageState();
}

class _AddMeasurementButtonPageState extends State<AddMeasurementButtonPage> {
  final _formKey = GlobalKey<FormState>();

  DateTime? selectedTime;
  DateTime? buttonPressTime;

  String tag = '';

  void _updateTime(DateTime newTime) {
    setState(() {
      selectedTime = newTime;
    });
  }

  void _updateTag(String newTag) {
    setState(() {
      tag = newTag;
    });
  }

  void _showSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Measurement Added to Current Timing Run!'),
        duration: Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Measurement',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        //title:  Text('Add New Measurement', style: TextStyle(color: Colors.black)),
      ),
      body: Consumer(builder: (context, ref, _) {
        final timingMeasurementListProvider = ref
            .watch(timingMeasurementsListProvider(widget.timingRunId).notifier);

        DateTime timeForPicker = DateTime.now();

        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                      "Move the dial to pick a time. Tap \"Add Measurement\" when your watch reaches the time displayed.",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 18),
                      textAlign: TextAlign.center),
                  Divider(),
                  ConfigurablePrecisionTimePicker(
                    onTimeChanged: _updateTime,
                    initialTime: timeForPicker,
                    mode: TimePickerMode.tap,
                  ),
                  // Tag selection section
                  TagSelector(
                    onTagSelected: _updateTag,
                    selectedTag: tag,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: PrimaryButton(
                        child: Text(
                          'Add Measurement',
                          style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onPrimary),
                        ),
                        onPressed: () async {
                          buttonPressTime = DateTime.now();
                          print(timeForPicker);
                          selectedTime = selectedTime ?? timeForPicker;

                          final ulid = Ulid();
                          final id = ulid.toString();

                          final measurement = TimingMeasurement(
                              id: id,
                              run_id: widget.timingRunId,
                              system_time: buttonPressTime!,
                              user_input_time: selectedTime,
                              image: null,
                              tag: tag, // Set the tag
                              difference_ms: selectedTime!
                                  .difference(buttonPressTime!)
                                  .inMilliseconds);

                          timingMeasurementListProvider
                              .addTimingMeasurement(measurement);
                          _showSnackBar();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
