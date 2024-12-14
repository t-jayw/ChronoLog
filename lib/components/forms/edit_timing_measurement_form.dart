import 'package:chronolog/components/measurement/photo_measurement_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../../models/timing_measurement.dart';
import '../../providers/timing_measurements_list_provider.dart';
import '../measurement/tag_selector.dart';
import '../primary_button.dart'; // Include the TagSelector component

String formatDateTimeWithMillis(DateTime dateTime) {
  final datePart = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  final millis = dateTime.millisecond;
  return '$datePart.$millis';
}

class EditTimingMeasurementForm extends StatefulWidget {
  final TimingMeasurement timingMeasurement;

  const EditTimingMeasurementForm({Key? key, required this.timingMeasurement})
      : super(key: key);

  @override
  _EditTimingMeasurementFormState createState() =>
      _EditTimingMeasurementFormState();
}

class _EditTimingMeasurementFormState extends State<EditTimingMeasurementForm> {
  final _formKey = GlobalKey<FormState>();
  late TimingMeasurement _editedTimingMeasurement;
  late DateTime _systemTime;
  late DateTime? _userInputTime;
  late String? tag; // Added
  bool _isEditingTime = false; // Added

  @override
  void initState() {
    super.initState();
    _editedTimingMeasurement = widget.timingMeasurement;
    _systemTime = _editedTimingMeasurement.system_time;
    _userInputTime = _editedTimingMeasurement.user_input_time;
    tag = _editedTimingMeasurement.tag; // Initialize with existing tag
  }

  void _toggleEditingTime() {
    // Added
    setState(() {
      _isEditingTime = !_isEditingTime;
    });
  }

  void _saveForm(BuildContext context, WidgetRef ref) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Keep the original system time
      final originalSystemTime = _editedTimingMeasurement.system_time;

      // Calculate difference using the original system time
      int differenceMs = _userInputTime != null
          ? _userInputTime!.difference(originalSystemTime).inMilliseconds
          : 0;

      _editedTimingMeasurement = _editedTimingMeasurement.copyWith(
        system_time: originalSystemTime, // Use original system time
        user_input_time: _userInputTime,
        tag: tag,
        difference_ms: differenceMs,
      );

      ref
          .watch(timingMeasurementsListProvider(_editedTimingMeasurement.run_id)
              .notifier)
          .updateTimingMeasurement(_editedTimingMeasurement);

      Navigator.of(context).pop();
    }
  }

  void _updateTag(String newTag) {
    setState(() {
      tag = newTag;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: Text('Edit Measurement',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: const EdgeInsets.all(8.0), // Padding inside the container
            decoration: BoxDecoration(
              border: Border.all(
                  color: Colors.black), // Black border around the container
              borderRadius: BorderRadius.circular(
                  8.0), // optional, if you want the container to have rounded corners
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ... Your existing code

                  // Added tag selector
                  Divider(),

                  SizedBox(height: 10),
                  RichText(
                    textAlign: TextAlign.left,
                    text: TextSpan(
                      text: 'System Time: ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: '${formatDateTimeWithMillis(_systemTime)}',
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color:
                                  Theme.of(context).colorScheme.onBackground),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  SizedBox(height: 5),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          textAlign: TextAlign.left,
                          text: TextSpan(
                            text: 'User Input Time: ',
                            style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.tertiary),
                            children: <TextSpan>[
                              TextSpan(
                                text:
                                    '${_userInputTime != null ? formatDateTimeWithMillis(_userInputTime!) : 'Not Set'}',
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(_isEditingTime ? Icons.done : Icons.edit),
                          onPressed: _toggleEditingTime,
                        ),
                      ]),
                  if (_isEditingTime)
                    CustomTimePicker(
                      initialTime: _userInputTime ?? DateTime.now(),
                      onTimeChanged: (newTime) {
                        setState(() {
                          _userInputTime = newTime;
                        });
                      },
                    ),
                  Divider(),
                  TagSelector(
                    onTagSelected: _updateTag,
                    selectedTag: tag,
                  ),
                  Divider(),
                  SizedBox(height: 10),
                  Consumer(
                    builder: (context, ref, _) {
                      return Container(
                          alignment: Alignment.center,
                          width: double.infinity,
                          child: PrimaryButton(
                              onPressed: () => _saveForm(context, ref),
                              child: Text(
                                'Save',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
                              )));
                    },
                  ),

                  Divider(),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
