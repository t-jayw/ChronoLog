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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _showInstructionsDialog();
      _pickImage(ImageSource.camera);
    });
  }

  Future<void> _showInstructionsDialog() async {
    if (!mounted) return; // Check if the widget is still mounted
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(
            'Instructions',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Take a photo of your watch face and note the time it shows.',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(
                'OK',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSuccessDialog(BuildContext context) async {
    if (!mounted) return; // Ensure the widget is still mounted
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
    if (!mounted) return; // Ensure the widget is still mounted
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
              Navigator.pop(ctx); // Close the dialog
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
        final timingMeasurementListProvider = ref
            .watch(timingMeasurementsListProvider(widget.timingRunId).notifier);

        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
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
      difference_ms: selectedTime.difference(imageTakenTime).inMilliseconds,
    );

    // Save the measurement
    await timingMeasurementListProvider.addTimingMeasurement(measurement);


    // Show success dialog
    await _showSuccessDialog(context);
  } catch (error) {
    await _showErrorDialog(error.toString());
  }
}

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
