import 'dart:io';
import 'package:chronolog/screens/watch_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ulid/ulid.dart';
import '../components/forms/form_components.dart';
import '../components/primary_button.dart';
import '../models/timepiece.dart';
import '../models/timing_run.dart';
import '../providers/timepiece_list_provider.dart';
import '../providers/timing_run_provider.dart';

String _formatDate(DateTime date) {
  // var locale = await DeviceLocale.getCurrentLocale();
  // var format = locale.startsWith('en_US') ? 'MM/dd/yyyy' : 'dd/MM/yyyy';
  var format = 'MM/dd/yyyy';
  return DateFormat(format).format(date);
}

void showFirstWatchAlert(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Congratulations!'),
        content: Text('You have added your first watch.'),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

class AddWatchScreen extends StatefulWidget {
  const AddWatchScreen({super.key});

  @override
  _AddWatchScreenState createState() => _AddWatchScreenState();
}

class _AddWatchScreenState extends State<AddWatchScreen> {
  final _formKey = GlobalKey<FormState>();
  String brand = '';
  String model = '';
  String serial = '';
  DateTime? purchaseDate;
  String notes = '';
  String? imageUrl;
  XFile? imageFile;
  CroppedFile? _croppedFile;
  String purchasePrice = '';
  String referenceNumber = '';
  String caliber = '';
  String crystalType = '';

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
          child: Scrollbar(
            thumbVisibility: true,
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
                              height: 180,
                            )
                          : Image.asset(
                              'assets/images/placeholder.png',
                              height: 180,
                            ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                                          Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Camera Button
                          FloatingActionButton(
                            heroTag: "btn1",
                            onPressed: () =>
                                _pickAndCropImage(ImageSource.camera),
                            child: Icon(Icons.camera_alt,
                                color: Theme.of(context).colorScheme.onPrimary),
                            backgroundColor:
                                Theme.of(context).colorScheme.tertiary,
                            mini:
                                true, // Use 'mini' for a smaller button if you prefer
                          ),
                          // Photo Roll Button
                          FloatingActionButton(
                            heroTag: "btn2",
                            onPressed: () =>
                                _pickAndCropImage(ImageSource.gallery),
                            child: Icon(Icons.photo_library,
                                color: Theme.of(context).colorScheme.onPrimary),
                            backgroundColor:
                                Theme.of(context).colorScheme.tertiary,
                            mini: true, // Similarly, use 'mini' for consistency
                          ),
                        ],
                      ),
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Brand (required)'),
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
                      decoration:
                          const InputDecoration(labelText: 'Model (required)'),
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
                      decoration:
                          const InputDecoration(labelText: 'Reference Number'),
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
                      onSaved: (value) {
                        notes = value ?? '';
                      },
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inverseSurface),
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(height: 58),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
      floatingActionButton: Consumer(builder: (context, ref, _) {
        final _timepieceListProvider =
            ref.watch(timepieceListProvider.notifier);
        return FloatingActionButton.extended(
          label: Text('Add Watch',
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onPrimary)),
          backgroundColor: Theme.of(context)
              .colorScheme
              .tertiary, // Set the background color here

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
                purchasePrice: purchasePrice,
                referenceNumber: referenceNumber,
                caliber: caliber,
                crystalType: crystalType,
                notes: notes,
                imageUrl: imageUrl,
                image: _croppedFile != null
                    ? File(_croppedFile!.path).readAsBytesSync()
                    : null,
              );

              bool isFirstAddedWatch = _timepieceListProvider.state.length == 0;

              //print(timepiece.toMap());
              _timepieceListProvider.addTimepiece(timepiece);
              _addTimingRun(id, ref);

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => WatchDetails(
                    timepiece: timepiece,
                    firstAdded: isFirstAddedWatch,
                  ), // Whatever screen you want to navigate to.
                ),
              );
            }
          },
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
