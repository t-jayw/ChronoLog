import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImageHelper {
  static Future<void> pickImage(ImageSource source, Function(XFile?) setImageFile) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    setImageFile(pickedFile);
  }

  static Future<void> cropImage(XFile? imageFile, Function(CroppedFile?) setCroppedFile) async {
    if (imageFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        aspectRatioPresets: [CropAspectRatioPreset.square],
      );
      setCroppedFile(croppedFile);
    }
  }
}

class DatePickerButton extends StatelessWidget {
  final TextEditingController controller;
  final Function(DateTime?) onDateChanged;
  final String labelText;
  final DateTime? initialDate;

  const DatePickerButton({
    required this.controller,
    required this.onDateChanged,
    required this.labelText,
    this.initialDate,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(labelText: labelText),
      onTap: () async {
        final pickedDate = await showModalBottomSheet<DateTime>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (BuildContext builder) {
            DateTime tempPickedDate = initialDate ?? DateTime.now();
            return SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                padding: EdgeInsets.all(16),
                height: MediaQuery.of(context).size.height / 3,
                child: Column(
                  
                  children: [
                    Text(labelText),
                    Expanded(
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.date,
                        initialDateTime: tempPickedDate,
                        onDateTimeChanged: (DateTime dateTime) {
                          tempPickedDate = dateTime;
                        },
                      ),
                    ),
                    Center(
                      child: CupertinoButton(
                        color: Theme.of(context).colorScheme.tertiary,
                        child: Text('Done',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary)),
                        onPressed: () {
                          Navigator.of(builder).pop(tempPickedDate);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );

        if (pickedDate != null) {
          onDateChanged(pickedDate);
        }
      },
      readOnly: true,
      controller: controller,
      style: TextStyle(color: Theme.of(context).colorScheme.inverseSurface),
    );
  }
}


class ImageDisplay extends StatefulWidget {
  final XFile? imageFile;
  final void Function(ImageSource source) onImagePick;

  const ImageDisplay({
    Key? key,
    required this.imageFile,
    required this.onImagePick,
  }) : super(key: key);

  @override
  _ImageDisplayState createState() => _ImageDisplayState();
}

class _ImageDisplayState extends State<ImageDisplay> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.imageFile != null)
          Image.file(
            File(widget.imageFile!.path),
            height: 200,
          )
        else
          Image.asset(
            'assets/images/placeholder.png',
            height: 200,
          ),
        SizedBox(
          height: 8,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CupertinoButton(
              padding: EdgeInsets.symmetric(vertical: 8),
              color: Theme.of(context).colorScheme.tertiary,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.camera,
                    size: 20,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Camera',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
              onPressed: () {
                widget.onImagePick(ImageSource.camera);
              },
            ),
            SizedBox(width: 8),
            CupertinoButton(
              padding: EdgeInsets.symmetric(vertical: 8),
              color: Theme.of(context).colorScheme.tertiary,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.photo,
                    size: 20,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Photo Roll',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
              onPressed: () {
                widget.onImagePick(ImageSource.gallery);
              },
            ),
          ],
        ),
      ],
    );
  }
}
