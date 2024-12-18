import 'package:chronolog/components/measurement/configurable_picker.dart';
import 'package:flutter/cupertino.dart';
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

  Future<void> _showSuccessDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(
          "Success",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Text(
          "Measurement added successfully!",
          style: TextStyle(fontSize: 16),
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text(
              "OK",
              style: TextStyle(color: Colors.blue),
            ),
            onPressed: () {
              Navigator.pop(ctx); // Close the dialog
              Navigator.pop(context); // Pop the current screen
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showErrorDialog(
      BuildContext context, String errorMessage) async {
    await showDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(
          "Error",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Text(
          errorMessage,
          style: TextStyle(fontSize: 16),
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text(
              "OK",
              style: TextStyle(color: Colors.blue),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Measurement',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
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
                  // Updated Collapsible Instructional Section
                  ExpansionTile(
                    title: Text(
                      'How to Add a Measurement',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    leading: Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '1. **Set Time:** Use the picker to select the time for your measurement.',
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '2. **Choose Tag:** Select a tag to categorize your measurement.',
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '3. **Add Measurement:** Tap the "Add Measurement" button to save it.',
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'A confirmation message will appear once your measurement is added.',
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Existing Widgets
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
                          if (!_formKey.currentState!.validate()) {
                            await _showErrorDialog(context,
                                'Please complete the form before adding a measurement.');
                            return;
                          }

                          setState(() {
                            buttonPressTime = DateTime.now();
                            selectedTime = selectedTime ?? timeForPicker;
                          });

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
                                .inMilliseconds,
                          );

                          try {
                            await timingMeasurementListProvider
                                .addTimingMeasurement(measurement);

                            if (mounted) {
                              // Show success snackbar before navigating back
                              await _showSuccessDialog(context);

                              // Delay the pop slightly to ensure the snackbar shows
                              Future.delayed(Duration(milliseconds: 0), () {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }
                              });
                            }
                          } catch (error) {
                            if (mounted) {
                              await _showErrorDialog(context, error.toString());
                            }
                          }
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
