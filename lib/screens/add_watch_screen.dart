import 'dart:io';
import 'package:chronolog/components/brand_list.dart';
import 'package:chronolog/screens/watch_details_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ulid/ulid.dart';
import '../components/forms/form_components.dart';
import '../models/timepiece.dart';
import '../models/timing_run.dart';
import '../providers/timepiece_list_provider.dart';
import '../providers/timing_run_provider.dart';
import 'package:flutter_svg/svg.dart';

String _formatDate(DateTime date) {
  var format = 'MM/dd/yyyy';
  return DateFormat(format).format(date);
}

void showFirstWatchAlert(BuildContext context) {
  showCupertinoDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text('Congratulations!'),
        content: Text('You have added your first watch.'),
        actions: [
          CupertinoDialogAction(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    },
  );
}

class CustomEditableField extends StatefulWidget {
  final String label;
  final String placeholder;
  final void Function(String) onChanged;
  final String initialValue;
  final TextInputType keyboardType;
  final bool obscureText;

  const CustomEditableField({
    Key? key,
    required this.label,
    required this.placeholder,
    required this.onChanged,
    this.initialValue = '',
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
  }) : super(key: key);

  @override
  _CustomEditableFieldState createState() => _CustomEditableFieldState();
}

class _CustomEditableFieldState extends State<CustomEditableField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Make fields as condensed as possible
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
            decoration: TextDecoration.none,
            fontSize: 12,
          ),
        ),
        SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
            borderRadius: BorderRadius.circular(6),
          ),
          child: CupertinoTextField(
            controller: _controller,
            placeholder: widget.placeholder,
            onChanged: widget.onChanged,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: null,
            style: TextStyle(
              color: CupertinoColors.label.resolveFrom(context),
              fontSize: 18,
            ),
            placeholderStyle: TextStyle(
              color: CupertinoColors.placeholderText.resolveFrom(context),
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class CustomEditableTextArea extends StatefulWidget {
  final String label;
  final String placeholder;
  final void Function(String) onChanged;
  final String initialValue;

  const CustomEditableTextArea({
    Key? key,
    required this.label,
    required this.placeholder,
    required this.onChanged,
    this.initialValue = '',
  }) : super(key: key);

  @override
  _CustomEditableTextAreaState createState() => _CustomEditableTextAreaState();
}

class _CustomEditableTextAreaState extends State<CustomEditableTextArea> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
            fontSize: 12,
            decoration: TextDecoration.none,
          ),
        ),
        SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
            borderRadius: BorderRadius.circular(6),
          ),
          child: CupertinoTextField(
            controller: _controller,
            placeholder: widget.placeholder,
            onChanged: widget.onChanged,
            minLines: 4,
            maxLines: 8,
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: null,
            style: TextStyle(
              color: CupertinoColors.label.resolveFrom(context),
              fontSize: 16,
            ),
            placeholderStyle: TextStyle(
              color: CupertinoColors.placeholderText.resolveFrom(context),
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class AddWatchScreen extends StatefulWidget {
  const AddWatchScreen({super.key});

  @override
  _AddWatchScreenState createState() => _AddWatchScreenState();
}

class _AddWatchScreenState extends State<AddWatchScreen> {
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
  final TextEditingController _brandController = TextEditingController();
  List<String> _brandSuggestions = [];

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

  Future<void> _showDatePicker() async {
    DateTime initialDate = purchaseDate ?? DateTime.now();
    await showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 180,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Expanded(
              child: CupertinoDatePicker(
                initialDateTime: initialDate,
                mode: CupertinoDatePickerMode.date,
                onDateTimeChanged: (DateTime date) {
                  setState(() {
                    purchaseDate = date;
                  });
                },
              ),
            ),
            CupertinoButton(
              child: Text('Done', style: TextStyle(fontSize: 12)),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      ),
    );
  }

  void _validateAndSubmit(WidgetRef ref) {
    if (brand.isEmpty || model.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text('Missing Fields'),
          content: Text('Please fill in both brand and model fields.'),
          actions: [
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      );
      return;
    }

    final ulid = Ulid();
    final id = ulid.toString();

    final timepiece = Timepiece(
      id: id,
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
          : null,
    );

    final _timepieceListProvider = ref.watch(timepieceListProvider.notifier);

    bool isFirstAddedWatch = _timepieceListProvider.state.isEmpty;

    _timepieceListProvider.addTimepiece(timepiece);
    _addTimingRun(id, ref);

    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
        builder: (BuildContext context) => WatchDetails(
          timepiece: timepiece,
          firstAdded: isFirstAddedWatch,
        ),
      ),
    );
  }

  void _updateBrandSuggestions(String query) {
    setState(() {
      brand = query;
      if (query.isEmpty) {
        _brandSuggestions = [];
      } else {
        _brandSuggestions = brandsList
            .where((brand) =>
                brand.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _brandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Watch',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: Consumer(builder: (context, ref, _) {
          return Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Image and camera buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: _croppedFile != null
                                    ? Image.file(
                                        File(_croppedFile!.path),
                                        height: 80,
                                        fit: BoxFit.cover,
                                      )
                                    : SvgPicture.asset(
                                        'assets/images/watch_placeholder.svg',
                                        height: 80,
                                        fit: BoxFit.cover,
                                        colorFilter: ColorFilter.mode(
                                          Theme.of(context).colorScheme.onSurface,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: CupertinoButton(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                color: Theme.of(context)
                                    .colorScheme
                                    .tertiary
                                    .withOpacity(0.8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      CupertinoIcons.camera,
                                      size: 20,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Camera',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                onPressed: () =>
                                    _pickAndCropImage(ImageSource.camera),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: CupertinoButton(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                color: Theme.of(context)
                                    .colorScheme
                                    .tertiary
                                    .withOpacity(0.8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      CupertinoIcons.photo,
                                      size: 20,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Gallery',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                onPressed: () =>
                                    _pickAndCropImage(ImageSource.gallery),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),

                        // Fields
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Brand*',
                              style: TextStyle(
                                color: CupertinoColors.secondaryLabel.resolveFrom(context),
                                decoration: TextDecoration.none,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 6),
                            Container(
                              decoration: BoxDecoration(
                                color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: CupertinoTextField(
                                controller: _brandController,
                                placeholder: '',
                                onChanged: _updateBrandSuggestions,
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                                decoration: null,
                                style: TextStyle(
                                  color: CupertinoColors.label.resolveFrom(context),
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            if (_brandSuggestions.isNotEmpty)
                              Container(
                                constraints: BoxConstraints(maxHeight: 150),
                                margin: EdgeInsets.only(top: 4),
                                decoration: BoxDecoration(
                                  color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: ListView.builder(
                                  itemCount: _brandSuggestions.length,
                                  itemBuilder: (context, index) {
                                    return CupertinoButton(
                                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          _brandSuggestions[index],
                                          style: TextStyle(
                                            color: CupertinoColors.label.resolveFrom(context),
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          brand = _brandSuggestions[index];
                                          _brandController.text = _brandSuggestions[index];
                                          _brandSuggestions = [];
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 12),
                        CustomEditableField(
                          label: 'Model*',
                          placeholder: '',
                          onChanged: (val) => model = val,
                        ),
                        SizedBox(height: 12),
                        CustomEditableField(
                          label: 'Serial',
                          placeholder: '',
                          onChanged: (val) => serial = val,
                        ),
                        SizedBox(height: 12),
                        // Purchase date row
                        Text('Purchase Date',
                            style: TextStyle(
                              color: CupertinoColors.secondaryLabel
                                  .resolveFrom(context),
                              decoration: TextDecoration.none,
                              fontSize: 12,
                            )),
                        SizedBox(height: 4),
                        Container(
                          decoration: BoxDecoration(
                            color: CupertinoColors.tertiarySystemFill
                                .resolveFrom(context),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: CupertinoButton(
                            onPressed: _showDatePicker,
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 6),
                            child: Text(
                              purchaseDate != null
                                  ? _formatDate(purchaseDate!)
                                  : '',
                              style: TextStyle(
                                color:
                                    CupertinoColors.label.resolveFrom(context),
                                fontSize: 13,
                                decoration: TextDecoration.none,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        CustomEditableField(
                          label: 'Price',
                          placeholder: '',
                          onChanged: (val) => purchasePrice = val,
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 12),
                        CustomEditableField(
                          label: 'Ref #',
                          placeholder: '',
                          onChanged: (val) => referenceNumber = val,
                        ),
                        SizedBox(height: 12),
                        CustomEditableField(
                          label: 'Caliber',
                          placeholder: '',
                          onChanged: (val) => caliber = val,
                        ),
                        SizedBox(height: 12),
                        CustomEditableField(
                          label: 'Crystal',
                          placeholder: '',
                          onChanged: (val) => crystalType = val,
                        ),
                        SizedBox(height: 12),
                        CustomEditableTextArea(
                          label: 'Notes',
                          placeholder: 'Enter notes about your timepiece...',
                          onChanged: (val) => notes = val,
                        ),
                      ],
                    ),
                  ),
                ),
                // Fixed Add Watch button
                CupertinoButton(
                  color: Theme.of(context).colorScheme.tertiary,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Add Watch',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => _validateAndSubmit(ref),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

void _addTimingRun(String watchId, WidgetRef ref) {
  final Ulid ulid = Ulid();
  final timingRunId = ulid.toString();
  final startTime = DateTime.now();
  final timingRun = TimingRun(
    id: timingRunId,
    watchId: watchId,
    startDate: startTime,
  );
  ref.read(timingRunProvider(watchId).notifier).addTimingRun(timingRun);
}
