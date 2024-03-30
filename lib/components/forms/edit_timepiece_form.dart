import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../models/timepiece.dart';
import '../../providers/timepiece_list_provider.dart';
import '../primary_button.dart';
import 'form_components.dart';

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
  String purchasePrice = '';
  String referenceNumber = '';
  String caliber = '';
  String crystalType = '';

  CroppedFile? _croppedFile;

  @override
  void initState() {
    brand = widget.timepiece.brand;
    model = widget.timepiece.model;
    serial = widget.timepiece.serial;
    purchaseDate = widget.timepiece.purchaseDate;
    notes = widget.timepiece.notes != null ? widget.timepiece.notes! : '';
    purchasePrice = widget.timepiece.purchasePrice ?? '';
    referenceNumber = widget.timepiece.referenceNumber ?? '';
    caliber = widget.timepiece.caliber ?? '';
    crystalType = widget.timepiece.crystalType ?? '';

    super.initState();
  }

  Future<void> _cropImage() async {
    ImageHelper.cropImage(imageFile, (croppedFile) {
      setState(() {
        _croppedFile = croppedFile;
      });
    });
  }

  Future<void> _pickAndCropImage(ImageSource source) async {
    ImageHelper.pickImage(source, (pickedFile) {
      setState(() {
        imageFile = pickedFile;
      });
      _cropImage();
    });
  }

  String _formatDate(DateTime date) {
    // var locale = await DeviceLocale.getCurrentLocale();
    // var format = locale.startsWith('en_US') ? 'MM/dd/yyyy' : 'dd/MM/yyyy';
    var format = 'MM/dd/yyyy';
    return DateFormat(format).format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Edit Watch',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        ),
        body: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _croppedFile != null
                            ? Image.file(
                                File(_croppedFile!.path),
                                height: 200,
                              )
                            : (widget.timepiece.image != null
                                ? Image.memory(
                                    widget.timepiece.image!,
                                    height: 180,
                                  )
                                : Image.asset(
                                    'assets/images/placeholder.png',
                                    height: 180,
                                  )),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          PrimaryButton(
                            child: Text(
                              'Add From Camera',
                              style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
                            ), // Use image icon
                            onPressed: () {
                              _pickAndCropImage(ImageSource.camera);
                            },
                          ),
                          PrimaryButton(
                            child: Text(
                              'Add From Photo Roll',
                              style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
                            ), // Use image icon
                            onPressed: () {
                              _pickAndCropImage(ImageSource.gallery);
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
                      DatePickerButton(
                        labelText: 'Purchase Date',
                        initialDate: purchaseDate,
                        controller: TextEditingController(
                          text: purchaseDate != null
                              ? _formatDate(purchaseDate!)
                              : '',
                        ),
                        onDateChanged: (date) {
                          setState(() {
                            purchaseDate = date;
                          });
                        },
                      ),
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Purchase Price'),
                        initialValue: purchasePrice,
                        onSaved: (value) => purchasePrice = value ?? '',
                        // Add any validators if needed
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'Reference Number'),
                        initialValue: referenceNumber,
                        onSaved: (value) => referenceNumber = value ?? '',
                        // Add any validators if needed
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Caliber'),
                        initialValue: caliber,
                        onSaved: (value) => caliber = value ?? '',
                        // Add any validators if needed
                      ),
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Crystal Type'),
                        initialValue: crystalType,
                        onSaved: (value) => crystalType = value ?? '',
                        // Add any validators if needed
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
                      const SizedBox(height: 58),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: Consumer(builder: (context, ref, _) {
          final _timepieceListProvider =
              ref.watch(timepieceListProvider.notifier);
          return FloatingActionButton.extended(
            label: Text('Save Changes',
                style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onPrimary)),
            backgroundColor: Theme.of(context)
                .colorScheme
                .tertiary, // Set the background color here
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();

                final timepiece = Timepiece(
                  id: widget.timepiece.id,
                  brand: brand,
                  model: model,
                  serial: serial,
                  purchaseDate: purchaseDate ?? DateTime.now(),
                  purchasePrice: purchasePrice,
                  referenceNumber: referenceNumber,
                  caliber: caliber,
                  crystalType: crystalType,
                  notes: notes,
                  imageUrl: imageUrl,
                  image: _croppedFile != null
                      ? File(_croppedFile!.path).readAsBytesSync()
                      : widget.timepiece.image,
                );

                _timepieceListProvider.updateTimepiece(timepiece);

                Navigator.of(context).pop();
              }
            },
          );
        }),
      );
    });
  }
}
