import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TimePickerMode { image, tap }

class ConfigurablePrecisionTimePicker extends StatefulWidget {
  final ValueChanged<DateTime> onTimeChanged;
  final DateTime initialTime;
  final TimePickerMode mode;

  const ConfigurablePrecisionTimePicker({
    Key? key,
    required this.onTimeChanged,
    required this.initialTime,
    this.mode = TimePickerMode.tap, // Default mode
  }) : super(key: key);

  @override
  _ConfigurablePrecisionTimePickerState createState() => _ConfigurablePrecisionTimePickerState();
}
class _ConfigurablePrecisionTimePickerState extends State<ConfigurablePrecisionTimePicker> {
  late int _selectedHour;
  late int _selectedMinute;
  late int _selectedSecond;
  late int _selectedTenthOfSecond;
  bool _isPM = false;
  bool _is24HourFormat = false; // Default to false for 12-hour format

  @override
  void initState() {
    super.initState();
    _loadTimeModePreference();
  }

  void _loadTimeModePreference() async {
    final prefs = await SharedPreferences.getInstance();
    // Assuming 'timeMode24Hour' is a stored preference where true indicates 24-hour format
    _is24HourFormat = prefs.getInt('timeModeOption') == 1 ? true : false;
    _initializePickerValues();
  }

  void _initializePickerValues() {
    DateTime currentTime = widget.initialTime;
    _selectedHour = currentTime.hour;
    if (!_is24HourFormat && currentTime.hour > 12) {
      _selectedHour = currentTime.hour - 12;
      _isPM = true;
    } else if (!_is24HourFormat && currentTime.hour == 0) {
      _selectedHour = 12;
    }
    _selectedMinute = currentTime.minute;
    _selectedSecond = widget.mode == TimePickerMode.tap ? (currentTime.second ~/ 5) * 5 : currentTime.second;
    _selectedTenthOfSecond = currentTime.millisecond ~/ 100;
    setState(() {});
  }

  void _updateTime() {
    int adjustedHour = _is24HourFormat || !_isPM ? _selectedHour : (_selectedHour % 12) + 12;
    DateTime updatedTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      adjustedHour,
      _selectedMinute,
      widget.mode == TimePickerMode.tap ? _selectedSecond : _selectedSecond,
      widget.mode == TimePickerMode.image ? _selectedTenthOfSecond * 100 : 0,
    );

    widget.onTimeChanged(updatedTime);
  }

  Widget _buildPicker(int selectedValue, int numberOfItems, int offset, ValueChanged<int> onSelectedItemChanged, {int step = 1}) {
    return SizedBox(
      height: 150,
      width: 50,
      child: CupertinoPicker(
        diameterRatio: 1.1,
        itemExtent: 60,
        looping: true,
        selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(),
        onSelectedItemChanged: onSelectedItemChanged,
        scrollController: FixedExtentScrollController(initialItem: selectedValue - offset),
        children: List<Widget>.generate(
            numberOfItems,
            (index) => Center(
                child: Text('${(index * step) + offset}'.padLeft(2, '0'),
                    style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onBackground)))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPicker(_selectedHour, _is24HourFormat ? 24 : 12, _is24HourFormat ? 0 : 1, (int value) {
          setState(() {
            _selectedHour = value + (_is24HourFormat ? 0 : 1);
            _updateTime();
          });
        }),
        Text(':', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onBackground)),
        _buildPicker(_selectedMinute, 60, 0, (int value) {
          setState(() {
            _selectedMinute = value;
            _updateTime();
          });
        }),
        if (widget.mode == TimePickerMode.tap)
          Text(':', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onBackground)),
        if (widget.mode == TimePickerMode.tap)
          _buildPicker(_selectedSecond ~/ 5, 12, 0, (int value) {
            setState(() {
              _selectedSecond = value * 5;
              _updateTime();
            });
          }, step: 5),
        if (widget.mode == TimePickerMode.image)
          Text('.', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onBackground)),
        if (widget.mode == TimePickerMode.image)
          _buildPicker(_selectedTenthOfSecond, 10, 0, (int value) {
            setState(() {
              _selectedTenthOfSecond = value;
              _updateTime();
            });
          }),
        if (!_is24HourFormat)
          Transform.scale(
            scale: 0.8,
            child: ToggleButtons(
              color: Theme.of(context).colorScheme.onBackground,
              selectedColor: Theme.of(context).colorScheme.onPrimary,
              fillColor: Theme.of(context).colorScheme.tertiary,
              borderColor: Theme.of(context).colorScheme.onBackground,
              borderRadius: BorderRadius.circular(10),
              onPressed: (int index) {
                setState(() {
                  _isPM = index == 1;
                  _updateTime();
                });
              },
              isSelected: [_isPM == false, _isPM == true],
              children: [
                Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('AM')),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('PM')),
              ],
            ),
          ),
      ],
    );
  }
}
