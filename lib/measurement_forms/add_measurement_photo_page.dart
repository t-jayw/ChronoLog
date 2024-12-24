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
  bool _tagsExpanded = false;

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
                          // Instructions Card moved to top
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
                                        color: CupertinoTheme.of(context).primaryColor,
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
                                      '1. Take a photo of your watch face\n'
                                      '2. Enter the exact time shown on the watch\n'
                                      '3. The app will compare this with the photo timestamp\n'
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

                          // Photo buttons (without preview)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: CupertinoButton(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              color: CupertinoTheme.of(context).primaryColor,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(CupertinoIcons.camera_fill,
                                      size: 24, color: CupertinoColors.white),
                                  SizedBox(width: 8),
                                  Text('Take Photo',
                                      style: TextStyle(
                                          color: CupertinoColors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                              onPressed: () => _pickImage(ImageSource.camera),
                            ),
                          ),
                          SizedBox(height: 12),

                          // Time Picker and Tag Selector with updated styling
                          Text(
                            'Enter time shown in photo',
                            style: TextStyle(
                              color: CupertinoColors.secondaryLabel.resolveFrom(context),
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 6),
                          ConfigurablePrecisionTimePicker(
                            onTimeChanged: _updateTime,
                            initialTime: DateTime.now(),
                            mode: TimePickerMode.image,
                          ),
                          SizedBox(height: 12),
                          
                          // Tag selector with expandable style
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
                        ],
                      ),
                    ),
                  ),
                ),
                // Add Measurement button at bottom
                CupertinoButton(
                  color: Theme.of(context).colorScheme.tertiary,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Add Measurement',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
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
          );
        }),
      ),
    );
  }
}
