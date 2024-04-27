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
  _ConfigurablePrecisionTimePickerState createState() =>
      _ConfigurablePrecisionTimePickerState();
}

class _ConfigurablePrecisionTimePickerState
    extends State<ConfigurablePrecisionTimePicker> {
  late int _selectedHour;
  late int _selectedMinute;
  late int _selectedSecond;
  late int _selectedTenthOfSecond;
  bool _isPM = false;
  bool _is24HourFormat = false; // Default to false for 12-hour format
  bool _isLoading = true;

  late FixedExtentScrollController _minutePickerController;
  late FixedExtentScrollController _hourPickerController;

  @override
  void initState() {
    super.initState();
    _loadTimeModePreference();

    _minutePickerController =
        FixedExtentScrollController(initialItem: widget.initialTime.minute);
    _hourPickerController =
        FixedExtentScrollController(initialItem: widget.initialTime.hour);
  }

  @override
  void dispose() {
    // Don't forget to dispose of the controller when the widget is removed
    _minutePickerController.dispose();
    super.dispose();
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

    if (!_is24HourFormat) {
      if (_selectedHour == 0) {
        _selectedHour = 12; // Midnight
        _isPM = false;
      } else if (_selectedHour > 12) {
        _selectedHour -= 12; // Afternoon/Evening
        _isPM = true;
      } else if (_selectedHour == 12) {
        // Noon
        _isPM = true;
      } else {
        // Morning
        _isPM = false;
      }
    }

    // Adjust initial item for hour picker controller based on 24-hour or 12-hour format
    _hourPickerController = FixedExtentScrollController(
      initialItem: _is24HourFormat
          ? _selectedHour
          : (_selectedHour % 12) - 1 + (_isPM ? 12 : 0),
    );

    _selectedMinute = currentTime.minute;
    _selectedSecond = widget.mode == TimePickerMode.tap
        ? (currentTime.second ~/ 5) * 5
        : currentTime.second;
    _selectedTenthOfSecond = currentTime.millisecond ~/ 100;

    setState(() {
      _isLoading = false;
    });
  }

  void _updateTime() {
    int adjustedHour =
        _is24HourFormat || !_isPM ? _selectedHour : (_selectedHour % 12) + 12;
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

  void _incrementHour() {
    if (_is24HourFormat) {
      _selectedHour = (_selectedHour + 1) % 24;
    } else {
      _selectedHour = (_selectedHour % 12) + 1;
      if (_selectedHour == 12) {
        // Check if we need to toggle AM/PM after rolling over
        _isPM = !_isPM;
      }
    }

    // Update the hour picker's index to reflect the change
    _hourPickerController
        .jumpToItem(_is24HourFormat ? _selectedHour : (_selectedHour % 12) - 1);
    setState(() {});
  }

  void _decrementHour() {
    if (_is24HourFormat) {
      _selectedHour = (_selectedHour - 1) < 0 ? 23 : _selectedHour - 1;
      _hourPickerController.jumpToItem(_selectedHour);
    } else {
      // Handling AM/PM toggle
      if (_selectedHour == 1 || _selectedHour == 0) {
        // Corrected condition to check for 1 instead of 0 for 12-hour format
        _isPM = !_isPM;
        _selectedHour = _selectedHour == 0
            ? 11
            : 12; // If it's 12 AM, roll back to 11 PM and vice versa
      } else {
        _selectedHour = (_selectedHour - 1) % 12;
        _selectedHour = _selectedHour == 0
            ? 12
            : _selectedHour; // Ensure we don't end up with 0 in a 12-hour format
      }
      // Adjust the index for 12-hour format picker, where `1` is represented by index `0`
      int pickerIndex = _selectedHour == 12 ? 11 : _selectedHour - 1;
      _hourPickerController.jumpToItem(pickerIndex);
    }

    // Force UI update
    setState(() {});
  }

// Helper method to handle second change logic
  void _handleSecondChange(int newSeconds) {
    bool incrementMinute = false;
    bool decrementMinute = false;

    // Detecting edge cases for rollover
    if (_selectedSecond >= 55 && newSeconds == 0) {
      // Rolled over to next minute
      incrementMinute = true;
      print('incrementMinute');
    } else if (_selectedSecond == 0 && newSeconds >= 55) {
      // Rolled over to previous minute
      decrementMinute = true;
      print('decrementMinute');
    }

    setState(() {
      _selectedSecond = newSeconds;

      if (incrementMinute) {
        _selectedMinute = (_selectedMinute + 1) % 60;
        _minutePickerController.jumpToItem(_selectedMinute);
      } else if (decrementMinute) {
        _selectedMinute = (_selectedMinute - 1) < 0 ? 59 : _selectedMinute - 1;
        _minutePickerController.jumpToItem(_selectedMinute);
      }

      _updateTime();
    });
  }

  Widget _buildPicker(
    int selectedValue,
    int numberOfItems,
    int offset,
    ValueChanged<int> onSelectedItemChanged, {
    int step = 1,
    FixedExtentScrollController? scrollController,
    bool loopingAllowed = true,
  } // Add this parameter
      ) {
    return SizedBox(
      height: 150,
      width: 50,
      child: CupertinoPicker(
        diameterRatio: 1.1,
        itemExtent: 60,
        looping: loopingAllowed,
        selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(),
        onSelectedItemChanged: onSelectedItemChanged,
        scrollController: scrollController ??
            FixedExtentScrollController(
                initialItem: selectedValue - offset), // Use the parameter here
        children: List<Widget>.generate(
            numberOfItems,
            (index) => Center(
                  child: Text('${(index * step) + offset}'.padLeft(2, '0'),
                      style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onBackground)),
                )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return CircularProgressIndicator(); // Or some placeholder
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Text('H', style: TextStyle(fontSize: 10)),
            _buildPicker(
              _selectedHour,
              _is24HourFormat ? 24 : 12,
              _is24HourFormat ? 0 : 1,
              (int value) {
                setState(() {
                  _selectedHour = value + (_is24HourFormat ? 0 : 1);
                  _updateTime();
                });
              },
              scrollController: _hourPickerController,
            ),
          ],
        ),
        Column(
          children: [
            Text('', style: TextStyle(fontSize: 10)),
            Text(':',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground)),
          ],
        ),
        Column(
          children: [
            Text('M', style: TextStyle(fontSize: 10)),
            _buildPicker(_selectedMinute, 60, 0, (int value) {
              // Before setting the new minute, capture the previous state to check for rollover
              bool isRollingOverIncrement = _selectedMinute == 59 && value == 0;
              bool isRollingOverDecrement = _selectedMinute == 0 && value == 59;

              setState(() {
                _selectedMinute = value;

                // Increment hour if rolling over from 59 to 0
                if (isRollingOverIncrement) {
                  print('icnrement hour');
                  _incrementHour();
                }
                // Decrement hour if rolling over from 0 to 59 (consider whether this should actually decrement the hour based on your application's logic)
                else if (isRollingOverDecrement) {
                  print('decrement hour');
                  _decrementHour();
                }

                _updateTime();
              });
            }, scrollController: _minutePickerController),
          ],
        ),

        Column(
          children: [
            Text('', style: TextStyle(fontSize: 10)),
            Text(':',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground)),
          ],
        ),
        // Include Seconds Picker for TimePickerMode.tap or TimePickerMode.image
        if (widget.mode == TimePickerMode.tap ||
            widget.mode == TimePickerMode.image)

          // Configure picker differently based on mode
          if (widget.mode == TimePickerMode.tap)
            Column(
              children: [
                Text('S', style: TextStyle(fontSize: 10)),
                _buildPicker(_selectedSecond ~/ 5, 12, 0, (int value) {
                  _handleSecondChange(value * 5);
                }, step: 5),
              ],
            ), // Tap mode: Mod 5 seconds picker
        if (widget.mode == TimePickerMode.image)
          Column(
            children: [
              Text('S', style: TextStyle(fontSize: 10)),
              _buildPicker(_selectedSecond, 60, 0, (int value) {
                _handleSecondChange(value);
              }),
            ],
          ), // Image mode: Every second picker

        if (widget.mode == TimePickerMode.image)
          Column(
            children: [
              Text('', style: TextStyle(fontSize: 10)),
              Text('.',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground)),
            ],
          ),
        if (widget.mode == TimePickerMode.image)
          Column(
            children: [
              Text('', style: TextStyle(fontSize: 10)),
              _buildPicker(
                _selectedTenthOfSecond,
                10,
                0,
                loopingAllowed: false,
                (int value) {
                  setState(() {
                    _selectedTenthOfSecond = value;

                    _updateTime();
                  });
                },
              ),
            ],
          ),
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
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('AM')),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('PM')),
              ],
            ),
          ),
      ],
    );
  }
}
