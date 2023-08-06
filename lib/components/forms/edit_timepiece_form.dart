import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/timepiece.dart';
import '../../providers/timepiece_list_provider.dart';
import '../primary_button.dart';

class EditTimepieceForm extends StatefulWidget {
  final Timepiece timepiece;
  const EditTimepieceForm({required this.timepiece, super.key});

  @override
  _EditTimepieceFormState createState() => _EditTimepieceFormState();
}

class _EditTimepieceFormState extends State<EditTimepieceForm> {
  final _formKey = GlobalKey<FormState>();
  String brand = '';
  String model = '';
  String serial = '';
  DateTime? purchaseDate;
  String notes = '';
  String? imageUrl;
  XFile? imageFile;

  CroppedFile? _croppedFile;

  @override
  void initState() {
    brand = widget.timepiece.brand;
    model = widget.timepiece.model;
    serial = widget.timepiece.serial;
    purchaseDate = widget.timepiece.purchaseDate;
    notes = widget.timepiece.notes != null ? widget.timepiece.notes! : '';

    super.initState();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    imageFile = pickedFile;
    _cropImage();
  }

  Future<void> _cropImage() async {
    if (imageFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        aspectRatioPresets: [CropAspectRatioPreset.square],
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
    return Consumer(builder: (context, ref, _) {
      final _timepieceListProvider = ref.watch(timepieceListProvider.notifier);

      return Scaffold(
          appBar: AppBar(
            title: Text('Edit Timepiece',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (imageFile != null)
                        Image.file(
                          File(_croppedFile!.path),
                          height: 200,
                        )
                      else if (widget.timepiece.image != null)
                        Image.memory(
                          widget.timepiece.image!,
                          height: 200,
                        )
                      else
                        Image.asset(
                          'assets/images/placeholder.png',
                          height: 200,
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          PrimaryButton(
                            child: Text(
                              'Camera',
                              style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
                            ), // Use image icon
                            onPressed: () {
                              _pickImage(ImageSource.camera);
                            },
                          ),
                          PrimaryButton(
                            child: Text(
                              'Photo Roll',
                              style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
                            ), // Use image icon
                            onPressed: () {
                              _pickImage(ImageSource.gallery);
                            },
                          ),
                        ],
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Brand'),
                        initialValue: brand,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a brand';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          brand = value ?? '';
                        },
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.inverseSurface),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Model'),
                        initialValue: model,
                        onSaved: (value) {
                          model = value ?? '';
                        },
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.inverseSurface),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Serial',
                        ),
                        initialValue: serial,
                        onSaved: (value) {
                          serial = value ?? '';
                        },
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.inverseSurface),
                      ),
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Purchase Date'),
                        onTap: () async {
                          final pickedDate =
                              await showModalBottomSheet<DateTime>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (BuildContext builder) {
                              DateTime tempPickedDate = DateTime.now();
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
                                  height:
                                      MediaQuery.of(context).size.height / 3,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: CupertinoDatePicker(
                                          mode: CupertinoDatePickerMode.date,
                                          initialDateTime: DateTime.now(),
                                          onDateTimeChanged:
                                              (DateTime dateTime) {
                                            tempPickedDate = dateTime;
                                          },
                                        ),
                                      ),
                                      Center(
                                        child: CupertinoButton(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiary,
                                          child: Text('Done',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary)),
                                          onPressed: () {
                                            Navigator.of(builder)
                                                .pop(tempPickedDate);
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
                            setState(() {
                              purchaseDate = pickedDate;
                            });
                          }
                        },
                        readOnly: true,
                        controller: TextEditingController(
                          text: purchaseDate != null
                              ? '${purchaseDate!.day}/${purchaseDate!.month}/${purchaseDate!.year}'
                              : '',
                        ),
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.inverseSurface),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Notes'),
                        initialValue: notes,
                        onSaved: (value) {
                          notes = value ?? '';
                        },
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.inverseSurface),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: PrimaryButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();

                                  final timepiece = Timepiece(
                                    id: widget.timepiece.id,
                                    brand: brand,
                                    model: model,
                                    serial: serial,
                                    purchaseDate:
                                        purchaseDate ?? DateTime.now(),
                                    notes: notes,
                                    imageUrl: imageUrl,
                                    image: _croppedFile != null
                                        ? File(_croppedFile!.path)
                                            .readAsBytesSync()
                                        : widget.timepiece.image,
                                  );

                                  _timepieceListProvider
                                      .updateTimepiece(timepiece);

                                  Navigator.of(context).pop();
                                }
                              },
                              child: Text(
                                'Save Changes',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
                              )),
                        ),
                      ),
                      const SizedBox(height: 58),
                    ],
                  ),
                ),
              ),
            ),
          ));
    });
  }
}
