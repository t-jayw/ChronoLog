import 'package:chronolog/components/measurement/configurable_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ulid/ulid.dart';
import '../components/measurement/tag_selector.dart';
import '../components/measurement/timing_measurement_item.dart';

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

  DateTime? selectedTime = DateTime.now();
  DateTime? buttonPressTime;

  String tag = '';

  bool _instructionsExpanded = false;
  bool _tagsExpanded = false;

  TimingMeasurement? previewMeasurement;

  void _updateTime(DateTime newTime) {
    setState(() {
      selectedTime = newTime;
      print("Time updated in picker: ${newTime.toIso8601String()}");
    });
  }

  void _updateTag(String newTag) {
    setState(() {
      tag = newTag;
    });
  }

  void _createPreviewMeasurement() {
    setState(() {
      // Get the time when the button is pressed (actual measurement time)
      final measurementTime = DateTime.now();
      
      if (selectedTime == null) {
        print("Error: No time selected in picker");
        return;
      }
      
      print("Selected time in picker: ${selectedTime!.toIso8601String()}");
      print("Button press time: ${measurementTime.toIso8601String()}");
      print("Difference in ms: ${measurementTime.difference(selectedTime!).inMilliseconds}");
      
      previewMeasurement = TimingMeasurement(
        id: Ulid().toString(),
        run_id: widget.timingRunId,
        system_time: measurementTime,
        user_input_time: selectedTime!, // Using the picker time directly
        image: null,
        tag: tag,
        difference_ms: measurementTime.difference(selectedTime!).inMilliseconds,
      );
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
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: Consumer(builder: (context, ref, _) {
          final timingMeasurementListProvider =
              ref.watch(timingMeasurementsListProvider(widget.timingRunId).notifier);
          
          // Get the existing measurements
          final measurements = ref.watch(timingMeasurementsListProvider(widget.timingRunId));
          
          // Get the most recent measurement (measurements are already sorted in descending order)
          final previousMeasurement = measurements.isNotEmpty ? measurements[0] : null;

          return Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Instructions Card
                          Container(
                            decoration: BoxDecoration(
                              color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: CupertinoButton(
                              padding: EdgeInsets.all(12),
                              onPressed: () {
                                setState(() {
                                  _instructionsExpanded = !_instructionsExpanded;
                                });
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        CupertinoIcons.info_circle,
                                        color: CupertinoColors.label.resolveFrom(context),
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'How to Add a Measurement',
                                        style: TextStyle(
                                          color: CupertinoColors.label.resolveFrom(context),
                                          fontSize: 14,
                                        ),
                                      ),
                                      Spacer(),
                                      Icon(
                                        _instructionsExpanded
                                            ? CupertinoIcons.chevron_up
                                            : CupertinoIcons.chevron_down,
                                        color: CupertinoColors.systemGrey,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                  if (_instructionsExpanded) ...[
                                    SizedBox(height: 12),
                                    Text(
                                      '1. Use the time selector to set a time slightly ahead of your watch\n'
                                      '2. Wait until your watch shows the time you selected\n'
                                      '3. When your watch matches the selected time, tap "Take Measurement"\n'
                                      '4. Optional: Add a tag to categorize your measurement',
                                      style: TextStyle(
                                        color: CupertinoColors.label.resolveFrom(context),
                                        fontSize: 14,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),

                          // Time Picker
                          Text(
                            'Choose a Time Ahead of Your Watch',
                            style: TextStyle(
                              color: CupertinoColors.secondaryLabel.resolveFrom(context),
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 6),
                          ConfigurablePrecisionTimePicker(
                            onTimeChanged: _updateTime,
                            initialTime: previewMeasurement?.user_input_time ?? DateTime.now(),
                            mode: TimePickerMode.tap,
                          ),
                          SizedBox(height: 12),

                          // Tag selector
                          Container(
                            decoration: BoxDecoration(
                              color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: CupertinoButton(
                              padding: EdgeInsets.all(12),
                              onPressed: () {
                                setState(() {
                                  _tagsExpanded = !_tagsExpanded;
                                });
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        CupertinoIcons.tag,
                                        color: CupertinoTheme.of(context).primaryColor,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Add Tag (Optional)',
                                        style: TextStyle(
                                          color: CupertinoColors.label.resolveFrom(context),
                                          fontSize: 14,
                                        ),
                                      ),
                                      Spacer(),
                                      Icon(
                                        _tagsExpanded
                                            ? CupertinoIcons.chevron_up
                                            : CupertinoIcons.chevron_down,
                                        color: CupertinoColors.systemGrey,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                  if (_tagsExpanded) ...[
                                    SizedBox(height: 12),
                                    TagSelector(
                                      onTagSelected: _updateTag,
                                      selectedTag: tag,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),

                          // New "Take Measurement" button
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: CupertinoButton(
                              color: Theme.of(context).colorScheme.secondary,
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Text('Take Measurement'),
                              onPressed: () {
                                if (!_formKey.currentState!.validate()) {
                                  _showErrorDialog(context, 'Please complete the form before capturing.');
                                  return;
                                }
                                _createPreviewMeasurement();
                              },
                            ),
                          ),

                          // Display the preview if available
                          if (previewMeasurement != null) ...[
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Preview',
                                    style: TextStyle(
                                      color: CupertinoColors.secondaryLabel.resolveFrom(context),
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  TimingMeasurementItem(
                                    timingMeasurement: previewMeasurement!,
                                    enableNavigation: false,
                                    previousMeasurement: previousMeasurement,
                                  ),
                                ],
                              ),
                            ),
                          ],
                          // Existing "Add Measurement" button
                          Row(
                            children: [
                              if (previewMeasurement != null)
                                Expanded(
                                  child: CupertinoButton(
                                    color: Theme.of(context).colorScheme.tertiary,
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text('Save Measurement'),
                                    onPressed: () async {
                                      try {
                                        await timingMeasurementListProvider.addTimingMeasurement(previewMeasurement!);
                                        if (mounted) {
                                          await _showSuccessDialog(context);
                                        }
                                      } catch (error) {
                                        if (mounted) {
                                          await _showErrorDialog(context, error.toString());
                                        }
                                      }
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
