import 'dart:io';

import 'package:chronolog/screens/tabs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ulid/ulid.dart';

import '../components/primary_button.dart';
import '../models/timepiece.dart';
import '../models/timing_run.dart';
import '../providers/timepiece_list_provider.dart';
import '../providers/timing_run_provider.dart';

Future<String> _formatDate(DateTime date) async {
  // var locale = await DeviceLocale.getCurrentLocale();
  // var format = locale.startsWith('en_US') ? 'MM/dd/yyyy' : 'dd/MM/yyyy';
  var format = 'MM/dd/yyyy';
  return DateFormat(format).format(date);
}

class AddWatchScreen extends StatefulWidget {
  const AddWatchScreen({super.key});

  @override
  _AddWatchScreenState createState() => _AddWatchScreenState();
}

class _AddWatchScreenState extends State<AddWatchScreen> {
  final _formKey = GlobalKey<FormState>();
  //String watchName = '';
  String brand = '';
  String model = '';
  String serial = '';
  //MovementType? movementType;
  DateTime? purchaseDate;
  String notes = '';
  String? imageUrl;
  XFile? imageFile;
  CroppedFile? _croppedFile;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Watch'),
      ),
      body: Consumer(builder: (context, ref, _) {
        final _timepieceListProvider =
            ref.watch(timepieceListProvider.notifier);

        return Padding(
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
                         PrimaryButton(
                            child: Text('Camera',                                           style: TextStyle(
                                              fontSize: 16,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary),), // Use image icon
                            onPressed: () {
                              _pickImage(ImageSource.gallery);
                            },
                          ),
                          PrimaryButton(
                            child: Text('Photo Roll',                                           style: TextStyle(
                                              fontSize: 16,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary),), // Use image icon
                            onPressed: () {
                              _pickImage(ImageSource.gallery);
                            },
                          ),
                        ],
                      ),
                  // TextFormField(
                  //   decoration: const InputDecoration(labelText: 'Watch Name'),
                  //   validator: (value) {
                  //     if (value == null || value.isEmpty) {
                  //       return 'Please enter a name';
                  //     }
                  //     return null;
                  //   },
                  //   onSaved: (value) {
                  //     watchName = value ?? '';
                  //   },
                  // ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Brand'),
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
                        color: Theme.of(context).colorScheme.inverseSurface),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Model'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a model';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      model = value ?? '';
                    },
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inverseSurface),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Serial'),
                    onSaved: (value) {
                      serial = value ?? '';
                    },
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inverseSurface),
                  ),
                  // DropdownButtonFormField<MovementType>(
                  //   decoration:
                  //       const InputDecoration(labelText: 'Movement Type'),
                  //   value: movementType,
                  //   items: MovementType.values.map((type) {
                  //     return DropdownMenuItem<MovementType>(
                  //       value: type,
                  //       child: Text(type.toString()),
                  //     );
                  //   }).toList(),
                  //   onChanged: (value) {
                  //     setState(() {
                  //       movementType = value;
                  //     });
                  //   },
                  //   onSaved: (value) {
                  //     movementType = value;
                  //   },
                  // ),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Purchase Date'),
                    onTap: () async {
                      final pickedDate = await showModalBottomSheet<DateTime>(
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
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                              ),
                              padding: EdgeInsets.all(16),
                              height: MediaQuery.of(context).size.height / 2.7,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: CupertinoDatePicker(
                                      mode: CupertinoDatePickerMode.date,
                                      initialDateTime: DateTime.now(),
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
                        color: Theme.of(context).colorScheme.inverseSurface),
                  ),

                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Notes'),
                    onSaved: (value) {
                      notes = value ?? '';
                    },
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inverseSurface),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    child: PrimaryButton(
                      child: Text('Add Watch',                                           style: TextStyle(
                                              fontSize: 18,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary),),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();

                          final ulid = Ulid();
                          final id = ulid.toString();

                          final timepiece = Timepiece(
                            id: id,
                            //name: watchName,
                            brand: brand,
                            model: model,
                            serial: serial,
                            //Type: movementType ?? MovementType.other,
                            purchaseDate: purchaseDate ?? DateTime.now(),
                            notes: notes,
                            imageUrl: imageUrl,
                            image: _croppedFile != null
                                ? File(_croppedFile!.path).readAsBytesSync()
                                : null,
                          );

                          //print(timepiece.toMap());
                          _timepieceListProvider.addTimepiece(timepiece);
                          _addTimingRun(id, ref);

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  TabsScreen(), // Whatever screen you want to navigate to.
                            ),
                          );
                        }
                      },
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

void _addTimingRun(String watchId, WidgetRef ref) {
  final Ulid ulid = Ulid();

  final timingRunId = ulid.toString();
  final startTime = DateTime.now();
  final timingRun = TimingRun(
    id: timingRunId,
    watch_id: watchId,
    startDate: startTime,
  );
  ref.read(timingRunProvider(watchId).notifier).addTimingRun(timingRun);
}
