import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../../models/timing_measurement.dart';
import '../../providers/timing_measurements_list_provider.dart';
import '../measurement/tag_selector.dart';
import '../measurement/configurable_picker.dart';
import '../measurement/timing_measurement_item.dart';

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

  bool _timeExpanded = false;
  bool _tagsExpanded = false;

  @override
  void initState() {
    super.initState();
    _editedTimingMeasurement = widget.timingMeasurement;
    _systemTime = _editedTimingMeasurement.system_time;
    _userInputTime =
        _editedTimingMeasurement.user_input_time ?? _editedTimingMeasurement.system_time;
    tag = _editedTimingMeasurement.tag;
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

      // Create a new TimingMeasurement with all fields to ensure complete update
      _editedTimingMeasurement = TimingMeasurement(
        id: _editedTimingMeasurement.id,
        run_id: _editedTimingMeasurement.run_id,
        system_time: _systemTime,
        user_input_time: _userInputTime,
        difference_ms: _userInputTime != null 
            ? _userInputTime!.difference(_systemTime).inMilliseconds
            : _systemTime.difference(_systemTime).inMilliseconds,
        tag: tag,
      );

      // Use read instead of watch for actions
      ref
          .read(timingMeasurementsListProvider(_editedTimingMeasurement.run_id).notifier)
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
      appBar: AppBar(
        title: Text(
          'Edit Measurement',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: Consumer(builder: (context, ref, _) {
          TimingMeasurement? previousMeasurement;
          final measurements = ref.read(timingMeasurementsListProvider(_editedTimingMeasurement.run_id));
          final sortedMeasurements = measurements.toList()
            ..sort((a, b) => b.system_time.compareTo(a.system_time));
          final currentIndex = sortedMeasurements.indexOf(_editedTimingMeasurement);
          
          if (currentIndex < sortedMeasurements.length - 1) {
            previousMeasurement = sortedMeasurements[currentIndex + 1];
          }

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
                          // System Time Display
                          Text(
                            'System Time',
                            style: TextStyle(
                              color:
                                  CupertinoColors.secondaryLabel.resolveFrom(context),
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 6),
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: CupertinoColors.tertiarySystemFill
                                  .resolveFrom(context),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              formatDateTimeWithMillis(_systemTime),
                              style: TextStyle(
                                color: CupertinoColors.label.resolveFrom(context),
                                fontSize: 14,
                              ),
                            ),
                          ),
                          SizedBox(height: 12),

                          // User Input Time Section
                          Container(
                            decoration: BoxDecoration(
                              color: CupertinoColors.tertiarySystemFill
                                  .resolveFrom(context),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: CupertinoButton(
                              padding: EdgeInsets.all(12),
                              onPressed: () {
                                setState(() {
                                  _timeExpanded = !_timeExpanded;
                                });
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        CupertinoIcons.time,
                                        color: CupertinoTheme.of(context)
                                            .primaryColor,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'User Input Time',
                                              style: TextStyle(
                                                color: CupertinoColors.secondaryLabel
                                                    .resolveFrom(context),
                                                fontSize: 12,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              _userInputTime != null
                                                  ? formatDateTimeWithMillis(
                                                      _userInputTime!)
                                                  : 'Not Set',
                                              style: TextStyle(
                                                color: CupertinoColors.label
                                                    .resolveFrom(context),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        _timeExpanded
                                            ? CupertinoIcons.chevron_up
                                            : CupertinoIcons.chevron_down,
                                        color: CupertinoColors.systemGrey,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                  if (_timeExpanded) ...[
                                    SizedBox(height: 12),
                                    ConfigurablePrecisionTimePicker(
                                      initialTime:
                                          _userInputTime ?? _systemTime,
                                      mode: TimePickerMode.image,
                                      onTimeChanged: (newTime) {
                                        setState(() {
                                          _userInputTime = newTime;
                                        });
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),

                          // Tag Section
                          Container(
                            decoration: BoxDecoration(
                              color: CupertinoColors.tertiarySystemFill
                                  .resolveFrom(context),
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
                                        color: CupertinoTheme.of(context)
                                            .primaryColor,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Edit Tag',
                                        style: TextStyle(
                                          color: CupertinoColors.label
                                              .resolveFrom(context),
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

                          // Preview Section Header
                          SizedBox(height: 20),
                          Divider(),
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'Preview',
                              style: TextStyle(
                                color: CupertinoColors.secondaryLabel.resolveFrom(context),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),

                          // Preview using TimingMeasurementItem
                          Consumer(builder: (context, ref, _) {
                            TimingMeasurement? previousMeasurement;
                            final measurements = ref.read(timingMeasurementsListProvider(_editedTimingMeasurement.run_id));
                            final sortedMeasurements = measurements.toList()
                              ..sort((a, b) => b.system_time.compareTo(a.system_time));
                            final currentIndex = sortedMeasurements.indexOf(_editedTimingMeasurement);
                            
                            if (currentIndex < sortedMeasurements.length - 1) {
                              previousMeasurement = sortedMeasurements[currentIndex + 1];
                            }

                            return TimingMeasurementItem(
                              timingMeasurement: TimingMeasurement(
                                id: _editedTimingMeasurement.id,
                                run_id: _editedTimingMeasurement.run_id,
                                system_time: _systemTime,
                                user_input_time: _userInputTime,
                                difference_ms: _userInputTime != null 
                                    ? _userInputTime!.difference(_systemTime).inMilliseconds
                                    : _systemTime.difference(_systemTime).inMilliseconds,
                                tag: tag,
                              ),
                              enableNavigation: false,
                              previousMeasurement: previousMeasurement,
                            );
                          }),

                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                // Separate Save Button
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: CupertinoButton(
                    color: Theme.of(context).colorScheme.primary,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      'Save Changes',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () => _saveForm(context, ref),
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
