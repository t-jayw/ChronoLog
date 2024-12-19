import 'dart:io';
import 'dart:typed_data';

import 'package:exif/exif.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ulid/ulid.dart';

import '../components/measurement/configurable_picker.dart';
import '../components/primary_button.dart';
import '../components/measurement/tag_selector.dart';
import '../models/timing_measurement.dart';
import '../providers/timing_measurements_list_provider.dart';

class AddMeasurementPhoto extends StatefulWidget {
  const AddMeasurementPhoto({super.key, required this.timingRunId});

  final String timingRunId;

  @override
  _AddMeasurementPhotoState createState() => _AddMeasurementPhotoState();
}

class _AddMeasurementPhotoState extends State<AddMeasurementPhoto> {
  final _formKey = GlobalKey<FormState>();
  XFile? imageFile;
  CroppedFile? _croppedFile;
  DateTime selectedTime = DateTime.now();
  DateTime imageTakenTime = DateTime.now();
  String tag = '';
  bool _instructionsExpanded = false;

  @override
  void initState() {
    super.initState();
    // Removed the call to show instructions dialog and auto camera pick.
    // The instructions will now be shown in a collapsible card, similar to the first file's style.
  }

  Future<void> _showSuccessDialog(BuildContext context) async {
    if (!mounted) return; 
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
              if (mounted) {
                Navigator.pop(context); // Pop the current screen
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showErrorDialog(String errorMessage) async {
    if (!mounted) return; 
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
            onPressed: () {
              Navigator.pop(ctx); 
            },
          ),
        ],
      ),
    );
  }

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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      imageFile = pickedFile;

      if (imageFile != null) {
        // Process EXIF data
        final fileBytes = File(imageFile!.path).readAsBytesSync();
        final data = await readExifFromBytes(fileBytes);

        if (data.containsKey('EXIF DateTimeOriginal')) {
          var dateTimeStr = data['EXIF DateTimeOriginal']!.printable;
          String formattedDateTime = dateTimeStr
              .replaceRange(4, 5, "-")
              .replaceRange(7, 8, "-")
              .replaceRange(10, 11, "T");
          imageTakenTime = DateTime.parse(formattedDateTime);
        } else {
          imageTakenTime = DateTime.now();
        }
        await _cropImage();
      }
    } catch (error) {
      await _showErrorDialog("Failed to pick image: $error");
    }
  }

  Future<void> _cropImage() async {
    try {
      if (imageFile != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: imageFile!.path,
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 100,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          cropStyle: CropStyle.circle,
        );
        if (croppedFile != null) {
          setState(() {
            _croppedFile = croppedFile;
          });
        }
      }
    } catch (error) {
      await _showErrorDialog("Failed to crop image: $error");
    }
  }

  Future<Uint8List> _readFileToBytes(String filePath) async {
    final File file = File(filePath);
    return await file.readAsBytes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Measurement',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
      ),
      body: Consumer(builder: (context, ref, _) {
        final timingMeasurementListProvider =
            ref.watch(timingMeasurementsListProvider(widget.timingRunId).notifier);

        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Instructions section (similar to first file)
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    elevation: 3,
                    child: ExpansionTile(
                      initiallyExpanded: false,
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
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      onExpansionChanged: (expanded) {
                        setState(() {
                          _instructionsExpanded = expanded;
                        });
                      },
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Step 1: Take a photo
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                  children: [
                                    TextSpan(text: '1. '),
                                    TextSpan(
                                      text: 'Take a Photo: ',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                        text:
                                            'Use the camera icon or the "Gallery" button to pick or take a photo of your watch face.'),
                                  ],
                                ),
                              ),
                              Divider(),
                              // Step 2: Note the time displayed on the watch
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                  children: [
                                    TextSpan(text: '2. '),
                                    TextSpan(
                                      text: 'Note the Time: ',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(text: 'Look at the watch face and remember the exact time it displays.'),
                                  ],
                                ),
                              ),
                              Divider(),
                              // Step 3: Set the user-input time in the time picker
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                  children: [
                                    TextSpan(text: '3. '),
                                    TextSpan(
                                      text: 'Select Time: ',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                        text:
                                            'Use the time picker below to set the measurement time that you saw on the watch face.'),
                                  ],
                                ),
                              ),
                              Divider(),
                              // Step 4: Tag (optional)
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                  children: [
                                    TextSpan(text: '4. '),
                                    TextSpan(
                                      text: 'Add a Tag (optional): ',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                        text:
                                            'If you like, select a tag to categorize your measurement.'),
                                  ],
                                ),
                              ),
                              Divider(),
                              // Step 5: Add Measurement
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                  children: [
                                    TextSpan(text: '5. '),
                                    TextSpan(
                                      text: 'Add Measurement: ',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(text: 'Tap "Add Measurement" to save.'),
                                  ],
                                ),
                              ),
                              Divider(),
                              // Confirmation message
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                  children: [
                                    TextSpan(
                                        text:
                                            'A confirmation message will appear once your measurement is added successfully.'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_croppedFile != null)
                    Image.file(File(_croppedFile!.path), height: 200)
                  else
                    GestureDetector(
                      onTap: () => _pickImage(ImageSource.camera),
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        child: Icon(Icons.camera_alt, size: 80),
                      ),
                    ),
                  const Divider(),
                  ConfigurablePrecisionTimePicker(
                    onTimeChanged: _updateTime,
                    initialTime: DateTime.now(),
                    mode: TimePickerMode.image,
                  ),
                  TagSelector(
                    onTagSelected: _updateTag,
                    selectedTag: tag,
                  ),
                  const SizedBox(height: 8),
                  PrimaryButton(
                    child: Text(
                      'Add Measurement',
                      style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                    onPressed: () async {
                      try {
                        final ulid = Ulid();
                        final id = ulid.toString();

                        Uint8List? imageBytes;
                        if (_croppedFile != null) {
                          imageBytes = await _readFileToBytes(_croppedFile!.path);
                        }

                        final measurement = TimingMeasurement(
                          id: id,
                          run_id: widget.timingRunId,
                          system_time: imageTakenTime,
                          user_input_time: selectedTime,
                          image: imageBytes,
                          tag: tag,
                          difference_ms:
                              selectedTime.difference(imageTakenTime).inMilliseconds,
                        );

                        // Save the measurement
                        await timingMeasurementListProvider.addTimingMeasurement(measurement);

                        // Show success dialog
                        await _showSuccessDialog(context);
                      } catch (error) {
                        await _showErrorDialog(error.toString());
                      }
                    },
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
