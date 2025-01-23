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
  late FixedExtentScrollController _secondPickerController;

  DateTime? _currentDateTime;

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
    // Dispose of all controllers when the widget is removed
    _minutePickerController.dispose();
    _hourPickerController.dispose();
    _secondPickerController.dispose();
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
        _selectedHour = 12; // Midnight (12 AM)
        _isPM = false;
      } else if (_selectedHour == 12) {
        // Noon (12 PM)
        _isPM = true;
      } else if (_selectedHour > 12) {
        _selectedHour -= 12; // Afternoon/Evening
        _isPM = true;
      } else {
        // Morning (1-11 AM)
        _isPM = false;
      }
    }

    // Update the hour picker controller initialization
    _hourPickerController = FixedExtentScrollController(
      initialItem: _is24HourFormat ? _selectedHour : (_selectedHour == 12 ? 11 : _selectedHour - 1),
    );

    _selectedMinute = currentTime.minute;
    _selectedSecond = currentTime.second;
    _selectedTenthOfSecond = currentTime.millisecond ~/ 100;

    // Initialize the seconds picker controller without mode-based adjustment
    _secondPickerController = FixedExtentScrollController(
      initialItem: _selectedSecond,
    );

    setState(() {
      _isLoading = false;
    });
  }

  void _updateTime() {
    int adjustedHour;
    if (_is24HourFormat) {
      adjustedHour = _selectedHour;
    } else {
      if (_isPM) {
        adjustedHour = _selectedHour == 12 ? 12 : _selectedHour + 12;
      } else {
        adjustedHour = _selectedHour == 12 ? 0 : _selectedHour;
      }
    }

    // Get current date components
    final now = DateTime.now();
    
    // First create the datetime without any date adjustment
    DateTime updatedTime = DateTime(
      now.year,
      now.month,
      now.day,
      adjustedHour,
      _selectedMinute,
      widget.mode == TimePickerMode.tap ? _selectedSecond : _selectedSecond,
      widget.mode == TimePickerMode.image ? _selectedTenthOfSecond * 100 : 0,
    );

    // Convert both times to their local time representations for comparison
    final nowLocal = now.toLocal();
    final updatedLocal = updatedTime.toLocal();

    // If the updated time is earlier than current time, move to next day
    if (updatedLocal.isBefore(nowLocal)) {
      updatedTime = updatedTime.add(const Duration(days: 1));
    }
    // If we're setting a time more than 12 hours ahead, assume we meant the previous day
    else if (updatedLocal.difference(nowLocal).inHours > 12) {
      updatedTime = updatedTime.subtract(const Duration(days: 1));
    }

    // Store the current time for display
    setState(() {
      _currentDateTime = updatedTime;
    });

    widget.onTimeChanged(updatedTime);
  }

  void _incrementHour() {
    setState(() {
      if (_is24HourFormat) {
        _selectedHour = (_selectedHour + 1) % 24;
      } else {
        if (_selectedHour == 11) {
          _selectedHour = 12;
          _isPM = !_isPM; // Toggle AM/PM when going from 11 to 12
        } else if (_selectedHour == 12) {
          _selectedHour = 1;
        } else {
          _selectedHour = _selectedHour + 1;
        }
      }

      _updateTime();  // Make sure we update the time after changing the hour

      // Update the hour picker's index
      int pickerIndex = _is24HourFormat 
          ? _selectedHour 
          : (_selectedHour == 12 ? 11 : _selectedHour - 1);
      _hourPickerController.jumpToItem(pickerIndex);
    });
  }

  void _decrementHour() {
    setState(() {
      if (_is24HourFormat) {
        _selectedHour = (_selectedHour - 1) < 0 ? 23 : _selectedHour - 1;
      } else {
        if (_selectedHour == 12) {
          _selectedHour = 11;
          _isPM = !_isPM; // Toggle AM/PM when going from 12 to 11
        } else if (_selectedHour == 1) {
          _selectedHour = 12;
        } else {
          _selectedHour = _selectedHour - 1;
        }
      }

      _updateTime();  // Make sure we update the time after changing the hour

      // Update the hour picker's index
      int pickerIndex = _is24HourFormat 
          ? _selectedHour 
          : (_selectedHour == 12 ? 11 : _selectedHour - 1);
      _hourPickerController.jumpToItem(pickerIndex);
    });
  }

  // Helper method to handle second change logic
  void _handleSecondChange(int newSeconds) {
    setState(() {
      bool incrementMinute = _selectedSecond > newSeconds && 
          (_selectedSecond - newSeconds) > 30; // Rolling forward
      bool decrementMinute = newSeconds > _selectedSecond && 
          (newSeconds - _selectedSecond) > 30; // Rolling backward

      _selectedSecond = newSeconds;

      if (incrementMinute) {
        _incrementMinute();
      } else if (decrementMinute) {
        _decrementMinute();
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
    bool isSubsecond = false,
  }) {
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
            FixedExtentScrollController(initialItem: selectedValue - offset),
        children: List<Widget>.generate(
            numberOfItems,
            (index) => Center(
                  child: Text(
                    isSubsecond 
                        ? '${(index * step) + offset}'
                        : '${(index * step) + offset}'.padLeft(2, '0'),
                    style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.onBackground)
                  ),
                )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return CircularProgressIndicator();
    }
    return Column(
      children: [
        // Add UTC time display in debug mode
        if (const bool.fromEnvironment('dart.vm.product') == false)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              _currentDateTime != null 
                ? 'UTC: ${_currentDateTime!.toUtc().toString()}'
                : 'UTC: Not set',
              style: TextStyle(
                color: Theme.of(context).colorScheme.tertiary,
                fontSize: 12,
              ),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hour Picker
            Column(
              children: [
                Text('H', style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.tertiary)),
                _buildPicker(
                  _selectedHour,
                  _is24HourFormat ? 24 : 12,
                  _is24HourFormat ? 0 : 1,
                  (int value) {
                    setState(() {
                      int newHour = value + (_is24HourFormat ? 0 : 1);
                      
                      if (!_is24HourFormat) {
                        // Check if we're crossing the 11/12 boundary
                        if (_selectedHour == 11 && newHour == 12) {
                          _isPM = !_isPM;
                        } else if (_selectedHour == 12 && newHour == 1) {
                          // Don't toggle AM/PM when going from 12 to 1
                        } else if (_selectedHour == 1 && newHour == 12) {
                          // Don't toggle AM/PM when going from 1 to 12
                        } else if (_selectedHour == 12 && newHour == 11) {
                          _isPM = !_isPM;
                        }
                      }
                      
                      _selectedHour = newHour;
                      _updateTime();
                    });
                  },
                  scrollController: _hourPickerController,
                ),
              ],
            ),
            // Hour-Minute Separator
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
            // Minute Picker
            Column(
              children: [
                Text('M', style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.tertiary)),
                _buildPicker(_selectedMinute, 60, 0, (int value) {
                  // Before setting the new minute, capture the previous state to check for rollover
                  bool isRollingOverIncrement = _selectedMinute == 59 && value == 0;
                  bool isRollingOverDecrement = _selectedMinute == 0 && value == 59;

                  setState(() {
                    _selectedMinute = value;

                    // Increment hour if rolling over from 59 to 0
                    if (isRollingOverIncrement) {
                      print('Increment hour');
                      _incrementHour();
                    }
                    // Decrement hour if rolling over from 0 to 59
                    else if (isRollingOverDecrement) {
                      print('Decrement hour');
                      _decrementHour();
                    }

                    _updateTime();
                  });
                }, scrollController: _minutePickerController),
              ],
            ),

            // Minute-Second Separator
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
            // Seconds Picker
            if (widget.mode == TimePickerMode.tap ||
                widget.mode == TimePickerMode.image)
              // Configure picker differently based on mode
              if (widget.mode == TimePickerMode.tap)
                Column(
                  children: [
                    Text('S', style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.tertiary)),
                    _buildPicker(
                      widget.mode == TimePickerMode.tap
                          ? _selectedSecond ~/ 5
                          : _selectedSecond,
                      widget.mode == TimePickerMode.tap ? 12 : 60,
                      0,
                      (int value) {
                        _handleSecondChange(widget.mode == TimePickerMode.tap
                            ? value * 5
                            : value);
                      },
                      step: widget.mode == TimePickerMode.tap ? 5 : 1,
                      scrollController: _secondPickerController,
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    Text('S', style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.tertiary)),
                    _buildPicker(
                      _selectedSecond,
                      60,
                      0,
                      (int value) {
                        _handleSecondChange(value);
                      },
                      scrollController: _secondPickerController,
                    ),
                  ],
                ),
            // Tenth of Second Picker (for Image Mode)
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
                    (int value) {
                      setState(() {
                        _selectedTenthOfSecond = value;
                        _updateTime();
                      });
                    },
                    isSubsecond: true,
                  ),
                ],
              ),
            // -5 Seconds Button with Icon and "5s" label
            Column(
              children: [
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedSecond =
                          (_selectedSecond - 5) < 0 ? 55 : _selectedSecond - 5; // Subtract 5 seconds
                      if (_selectedSecond == 55) {
                        _decrementMinute(); // Handle rollover
                      }

                      // Update the seconds picker controller
                      _secondPickerController.jumpToItem(
                          widget.mode == TimePickerMode.tap
                              ? (_selectedSecond ~/ 5)
                              : _selectedSecond);

                      _updateTime(); // Update the overall time
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.tertiary, // Outline color
                    ),
                    backgroundColor: Colors.transparent, // Transparent background
                    minimumSize: Size(40, 40), // Smaller size
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.remove,
                        size: 16,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '5s',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10), // Spacing between button and toggle
                // AM/PM Toggle (if not 24-hour format)
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('AM')),
                        Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('PM')),
                      ],
                    ),
                  ),
                SizedBox(height: 10), // Spacing between toggle and button
                // +5 Seconds Button with Icon and "5s" label
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedSecond =
                          (_selectedSecond + 5) % 60; // Add 5 seconds
                      if (_selectedSecond < 5) {
                        _incrementMinute(); // Handle rollover
                      }

                      // Update the seconds picker controller
                      _secondPickerController.jumpToItem(
                          widget.mode == TimePickerMode.tap
                              ? (_selectedSecond ~/ 5)
                              : _selectedSecond);

                      _updateTime(); // Update the overall time
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.tertiary, // Outline color
                    ),
                    backgroundColor: Colors.transparent, // Transparent background
                    minimumSize: Size(40, 40), // Smaller size
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add,
                        size: 16,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '5s',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        // Removed the original buttons Row
      ],
    );
  }

  // Helper methods to handle minute increment/decrement
  void _incrementMinute() {
    _selectedMinute = (_selectedMinute + 1) % 60;
    _minutePickerController.jumpToItem(_selectedMinute);
    _updateTime(); // Ensure time is updated
  }

  void _decrementMinute() {
    _selectedMinute = (_selectedMinute - 1) < 0 ? 59 : _selectedMinute - 1;
    _minutePickerController.jumpToItem(_selectedMinute);
    _updateTime(); // Ensure time is updated
  }
}
