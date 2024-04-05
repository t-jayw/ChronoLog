import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/timepiece.dart';
import '../../providers/timepiece_list_provider.dart';

import 'package:flutter_image_compress/flutter_image_compress.dart';



class AddImageForm extends StatefulWidget {
  final Timepiece timepiece;

  const AddImageForm({Key? key, required this.timepiece}) : super(key: key);

  @override
  _AddImageFormState createState() => _AddImageFormState();
}

class _AddImageFormState extends State<AddImageForm> {
  final _formKey = GlobalKey<FormState>();
  late Timepiece _editedTimepiece;
  late TextEditingController _brandController;
  XFile? imageFile;
  CroppedFile? _croppedFile;

  // Add controllers for other fields

  @override
  void initState() {
    super.initState();
    _editedTimepiece = widget.timepiece;
    _brandController = TextEditingController(text: _editedTimepiece.brand);
    // Initialize controllers for other fields
  }

  @override
  void dispose() {
    _brandController.dispose();
    // Dispose controllers for other fields
    super.dispose();
  }

  void _saveForm(BuildContext context, WidgetRef ref) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_croppedFile != null) {
        Timepiece newTimepiece = _editedTimepiece.copyWith(
            image: File(_croppedFile!.path).readAsBytesSync());
        _editedTimepiece = newTimepiece;
        // set imageFile to null after saving the new image to the timepiece
        imageFile = null;
      }

      // Update the Provider
      ref
          .read(timepieceListProvider.notifier)
          .updateTimepiece(_editedTimepiece);

      // Close the modal after updating the record
      Navigator.of(context).pop();
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    imageFile = pickedFile;

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
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
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
    return Form(
      key: _formKey,
      child: ListView(
        children: <Widget>[
          Container(
            width: double.infinity, // Fill the width of the screen
            height: 200,
            child: imageFile != null
                ? Image.file(
                    File(_croppedFile!.path),
                    fit: BoxFit.contain,
                  )
                : _editedTimepiece.image != null
                    ? Image.memory(
                        _editedTimepiece.image!,
                        fit: BoxFit.contain,
                      )
                    : Image.asset(
                        'assets/images/placeholder.png',
                        fit: BoxFit.contain,
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.camera_alt_outlined),
                    label: Text('Take Picture'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // Add round corners
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                    onPressed: () {
                      _pickImage(ImageSource.camera);
                    },
                  ),
                ),
                SizedBox(height: 10), // Spacer
                Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.photo_library_rounded),
                    label: Text('Select Picture'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // Add round corners
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                    onPressed: () {
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ),
                SizedBox(height: 10), // Spacer
                Consumer(
                  builder: (context, ref, _) {
                    return Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        child: Text('Save'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20), // Add round corners
                          ),
                          padding: EdgeInsets.symmetric(vertical: 15),
                          textStyle: TextStyle(fontSize: 18),
                        ),
                        onPressed: () => _saveForm(context, ref),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}