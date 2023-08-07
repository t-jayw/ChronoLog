import 'dart:io';
import 'dart:typed_data';

import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ulid/ulid.dart';

import '../components/photo_measurement_time_picker.dart';
import '../components/primary_button.dart';
import '../components/tag_selector.dart';
import '../models/timing_measurement.dart';

import '../providers/timing_measurements_list_provider.dart';

class AddMeasurementPhoto extends StatefulWidget {
  const AddMeasurementPhoto({super.key, required this.timingRunId});

  final String timingRunId;

  @override
  _AddMeasurementState createState() => _AddMeasurementState();
}

class _AddMeasurementState extends State<AddMeasurementPhoto> {
  final _formKey = GlobalKey<FormState>();
  XFile? imageFile;
  CroppedFile? _croppedFile;
  int? number;
  dynamic enteredTime;
  DateTime selectedTime = DateTime.now();
  DateTime imageTakenTime = DateTime.now();

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
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<Uint8List> _readFileToBytes(String filePath) async {
    final File file = File(filePath);
    return await file.readAsBytes();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    imageFile = pickedFile;

    imageTakenTime = DateTime.now();

    if (imageFile != null) {
      final fileBytes = File(imageFile!.path).readAsBytesSync();
      final data = await readExifFromBytes(fileBytes);

      if (data.isEmpty) {
        print("No EXIF information found");
      } else {
        if (data.containsKey('JPEGThumbnail')) {
          data.remove('JPEGThumbnail');
        }
        if (data.containsKey('TIFFThumbnail')) {
          data.remove('TIFFThumbnail');
        }
        if (data.containsKey('EXIF DateTimeOriginal')) {
          var dateTimeStr = data['EXIF DateTimeOriginal']!.printable;
          print('raw date time string:');
          print(dateTimeStr);

          String formattedDateTime = dateTimeStr
              .replaceRange(4, 5, "-")
              .replaceRange(7, 8, "-")
              .replaceRange(10, 11, "T");
          print(formattedDateTime);

          imageTakenTime = DateTime.parse(formattedDateTime);
        }
      }
    }
    _cropImage();
  }

  Future<void> _cropImage() async {
    print('crop');
    if (imageFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        cropStyle: CropStyle.circle,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Cropper',
          ),
          WebUiSettings(
            context: context,
            presentStyle: CropperPresentStyle.dialog,
            boundary: const CroppieBoundary(
              width: 520,
              height: 520,
            ),
            viewPort:
                const CroppieViewPort(width: 480, height: 480, type: 'circle'),
            enableExif: true,
            enableZoom: true,
            showZoomer: true,
          ),
        ],
      );
      if (croppedFile != null) {
        setState(() {
          _croppedFile = croppedFile;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.timingRunId);
    return Scaffold(
      appBar: AppBar(
        title:  Text('Add New Measurement', 
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
                    Image.file(
                      File(_croppedFile!.path),
                      height: 200,
                    )
                  else
                    InkWell(
                      onTap: () {
                        _pickImage(ImageSource.camera);
                      },
                      child: Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 80,
                        ),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      PrimaryButton(
                        child: Text('Take Photo',                                           style: TextStyle(
                                              fontSize: 16,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary),),
                        onPressed: () {
                          _pickImage(ImageSource.camera);
                        },
                      ),
                    ],
                  ),
                  const Divider(), // Add a horizontal line

                  CustomTimePicker(
                    initialTime: DateTime.now(),
                    onTimeChanged: _updateTime,
                  ),
                  TagSelector(
                    onTagSelected: _updateTag,
                    selectedTag: tag,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: double
                          .infinity, // this makes the button take the full width of the parent
                      height: 60, // adjust the height as you need
                      child: PrimaryButton(
                        child: Text('Add Measurement',                                           style: TextStyle(
                                              fontSize: 16,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary),),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();

                            final ulid = Ulid();
                            final id = ulid.toString();

                            Uint8List? imageBytes;
                            if (_croppedFile != null) {
                              imageBytes =
                                  await _readFileToBytes(_croppedFile!.path);
                            }

                            final measurement = TimingMeasurement(
                              id: id,
                              run_id: widget.timingRunId,
                              system_time: imageTakenTime,
                              user_input_time: selectedTime,
                              image: imageBytes,
                              difference_ms: selectedTime
                                  .difference(imageTakenTime)
                                  .inMilliseconds, // change `inSeconds` to whatever unit you want
                            );

                            timingMeasurementListProvider
                                .addTimingMeasurement(measurement);
                            _showSnackBar(); // Show snackbar

                            Navigator.of(context).pop();
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
