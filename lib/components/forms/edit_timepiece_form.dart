import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../models/timepiece.dart';
import '../../providers/timepiece_list_provider.dart';
import 'form_components.dart';

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
    // Similar styling to the first snippet:
    // Small label text, condensed spacing, larger text field font
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
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
    notes = widget.timepiece.notes ?? '';
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
    var format = 'MM/dd/yyyy';
    return DateFormat(format).format(date);
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

  void _saveChanges(WidgetRef ref) {
    // Validate logic similar to the AddWatchScreen:
    // If brand or model is empty, show an alert
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

    // Create updated timepiece
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

    final _timepieceListProvider = ref.watch(timepieceListProvider.notifier);
    _timepieceListProvider.updateTimepiece(timepiece);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Edit Watch', style: TextStyle(fontSize: 16)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: _croppedFile != null
                              ? Image.file(
                                  File(_croppedFile!.path),
                                  height: 80,
                                  fit: BoxFit.cover,
                                )
                              : (widget.timepiece.image != null
                                  ? Image.memory(
                                      widget.timepiece.image!,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      'assets/images/placeholder.png',
                                      height: 80,
                                      fit: BoxFit.cover,
                                    )),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: CupertinoButton(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                color: CupertinoTheme.of(context).primaryColor,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(CupertinoIcons.camera,
                                        size: 20, color: CupertinoColors.white),
                                    SizedBox(width: 8),
                                    Text('Camera',
                                        style: TextStyle(
                                            color: CupertinoColors.white,
                                            fontSize: 14)),
                                  ],
                                ),
                                onPressed: () => _pickAndCropImage(ImageSource.camera),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: CupertinoButton(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                color: CupertinoTheme.of(context).primaryColor,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(CupertinoIcons.photo,
                                        size: 20, color: CupertinoColors.white),
                                    SizedBox(width: 8),
                                    Text('Gallery',
                                        style: TextStyle(
                                            color: CupertinoColors.white,
                                            fontSize: 14)),
                                  ],
                                ),
                                onPressed: () => _pickAndCropImage(ImageSource.gallery),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        CustomEditableField(
                          label: 'Brand*',
                          placeholder: '',
                          initialValue: brand,
                          onChanged: (val) => brand = val,
                        ),
                        SizedBox(height: 12),
                        CustomEditableField(
                          label: 'Model*',
                          placeholder: '',
                          initialValue: model,
                          onChanged: (val) => model = val,
                        ),
                        SizedBox(height: 12),
                        CustomEditableField(
                          label: 'Serial',
                          placeholder: '',
                          initialValue: serial,
                          onChanged: (val) => serial = val,
                        ),
                        SizedBox(height: 12),
                        Text('Purchase Date',
                            style: TextStyle(
                              color: CupertinoColors.secondaryLabel
                                  .resolveFrom(context),
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
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                            child: Text(
                              purchaseDate != null ? _formatDate(purchaseDate!) : '',
                              style: TextStyle(
                                color: CupertinoColors.label.resolveFrom(context),
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        CustomEditableField(
                          label: 'Price',
                          placeholder: '',
                          initialValue: purchasePrice,
                          onChanged: (val) => purchasePrice = val,
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 12),
                        CustomEditableField(
                          label: 'Ref #',
                          placeholder: '',
                          initialValue: referenceNumber,
                          onChanged: (val) => referenceNumber = val,
                        ),
                        SizedBox(height: 12),
                        CustomEditableField(
                          label: 'Caliber',
                          placeholder: '',
                          initialValue: caliber,
                          onChanged: (val) => caliber = val,
                        ),
                        SizedBox(height: 12),
                        CustomEditableField(
                          label: 'Crystal',
                          placeholder: '',
                          initialValue: crystalType,
                          onChanged: (val) => crystalType = val,
                        ),
                        SizedBox(height: 12),
                        CustomEditableField(
                          label: 'Notes',
                          placeholder: '',
                          initialValue: notes,
                          onChanged: (val) => notes = val,
                        ),
                      ],
                    ),
                  ),
                ),
                CupertinoButton(
                  color: CupertinoTheme.of(context).primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Save Changes',
                    style: TextStyle(color: CupertinoColors.white, fontSize: 14),
                  ),
                  onPressed: () => _saveChanges(ref),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
