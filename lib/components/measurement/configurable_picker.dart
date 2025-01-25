import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:intl/intl.dart';

enum TimePickerMode { image, tap }

class ConfigurablePrecisionTimePicker extends StatefulWidget {
  final ValueChanged<DateTime> onTimeChanged;
  final DateTime? initialTime;
  final TimePickerMode mode;
  final Duration initialOffset;

  const ConfigurablePrecisionTimePicker({
    Key? key,
    required this.onTimeChanged,
    this.initialTime,
    this.mode = TimePickerMode.tap,
    this.initialOffset = const Duration(seconds: 5),
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

  late DateTime _deviceCurrentTime;
  late DateTime _selectedInDial;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    print("InitState - Initial time: ${widget.initialTime}");
    print("InitState - Current time: ${DateTime.now()}");
    _deviceCurrentTime = DateTime.now();
    _selectedInDial = widget.initialTime ?? _deviceCurrentTime.add(widget.initialOffset);
    print("InitState - Selected dial time: $_selectedInDial");
    
    // Update device time every second
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _deviceCurrentTime = DateTime.now();
      });
    });
    
    _loadTimeModePreference();

    _minutePickerController =
        FixedExtentScrollController(initialItem: widget.initialTime?.minute ?? 0);
    _hourPickerController =
        FixedExtentScrollController(initialItem: widget.initialTime?.hour ?? 0);
  }

  @override
  void dispose() {
    _timer.cancel();
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
    print("Initializing picker values:");
    print("Initial DateTime: ${_selectedInDial}");
    _selectedHour = _selectedInDial.hour;
    print("Initial hour (24h): $_selectedHour");

    if (!_is24HourFormat) {
      if (_selectedHour == 0) {
        _selectedHour = 12;
        _isPM = false;
      } else if (_selectedHour > 12) {
        _selectedHour -= 12;
        _isPM = true;
      } else if (_selectedHour == 12) {
        _isPM = true;
      } else {
        _isPM = false;
      }
    }
    print("Adjusted hour: $_selectedHour, isPM: $_isPM");

    // Fix: Correct initialItem calculation for hour picker
    int hourInitialItem = _is24HourFormat ? _selectedHour : (_selectedHour - 1);
    print("Hour picker initial item: $hourInitialItem");
    
    _hourPickerController = FixedExtentScrollController(
      initialItem: hourInitialItem,
    );

    _selectedMinute = _selectedInDial.minute;
    _selectedSecond = _selectedInDial.second;
    _selectedTenthOfSecond = _selectedInDial.millisecond ~/ 100;

    // Initialize the seconds picker controller without mode-based adjustment
    _secondPickerController = FixedExtentScrollController(
      initialItem: _selectedSecond,
    );

    setState(() {
      _isLoading = false;
    });
  }

  void _updateTime() {
    // Calculate the adjusted hour based on 12/24 hour format
    int adjustedHour;
    if (_is24HourFormat) {
      adjustedHour = _selectedHour;
    } else {
      if (_selectedHour == 12) {
        adjustedHour = _isPM ? 12 : 0;
      } else {
        adjustedHour = _isPM ? _selectedHour + 12 : _selectedHour;
      }
    }
    
    // Create new DateTime while preserving the existing date
    _selectedInDial = DateTime(
      _selectedInDial.year,  // Keep existing date components
      _selectedInDial.month,
      _selectedInDial.day,
      adjustedHour,
      _selectedMinute,
      _selectedSecond,
      0,
    );

    widget.onTimeChanged(_selectedInDial);
  }

  void _incrementHour() {
    if (_is24HourFormat) {
      _selectedHour = (_selectedHour + 1) % 24;
    } else {
      _selectedHour = (_selectedHour % 12) + 1;
      // Toggle AM/PM when crossing 11->12 or 12->1
      if (_selectedHour == 12) {
        _isPM = !_isPM;
      }
    }

    _hourPickerController.jumpToItem(_selectedHour - (_is24HourFormat ? 0 : 1));
    _updateTime();
    setState(() {});
  }

  void _decrementHour() {
    if (_is24HourFormat) {
      _selectedHour = (_selectedHour - 1) < 0 ? 23 : _selectedHour - 1;
      _hourPickerController.jumpToItem(_selectedHour);
    } else {
      if (_selectedHour == 12) {
        _selectedHour = 11;
        _isPM = !_isPM;
      } else if (_selectedHour == 1) {
        _selectedHour = 12;
        _isPM = !_isPM;
      } else {
        _selectedHour = (_selectedHour - 1) == 0 ? 12 : _selectedHour - 1;
      }
      _hourPickerController.jumpToItem(_selectedHour - 1);
    }

    _updateTime();
    setState(() {});
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

  void _handleHourChange(int value) {
    setState(() {
      if (_is24HourFormat) {
        _selectedHour = value;
      } else {
        _selectedHour = value + 1;
        // Toggle AM/PM when crossing 11->12 or 12->1
        if (_selectedHour == 12 && _isPM) {
          _isPM = false;
        } else if (_selectedHour == 12 && !_isPM) {
          _isPM = true;
        }
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

  Widget _buildDebugPanel() {
    Duration difference = _selectedInDial.difference(_deviceCurrentTime);
    
    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.tertiary),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Device Time: ${_deviceCurrentTime.toString()}'),
          Text('Selected Time: ${_selectedInDial.toString()}'),
          Text('Difference: ${difference.inSeconds} seconds'),
          ElevatedButton(
            onPressed: _toggleTimeFormat,
            child: Text(_is24HourFormat ? 'Switch to 12h' : 'Switch to 24h'),
          ),
        ],
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
        _buildDebugPanel(),
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
                  _handleHourChange,
                  scrollController: _hourPickerController,
                  loopingAllowed: true,
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
            // Add AM/PM indicator after the last picker
            if (!_is24HourFormat)
              Padding(
                padding: EdgeInsets.only(left: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('', style: TextStyle(fontSize: 10)),  // Empty space to align with pickers
                    Text(
                      _isPM ? 'PM' : 'AM',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        // Compact date display
        Container(
          margin: EdgeInsets.only(top: 8),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedInDial = _selectedInDial.subtract(Duration(days: 1));
                    _updateTime();
                  });
                },
                child: Icon(
                  CupertinoIcons.chevron_left,
                  size: 14,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  DateFormat('MMM d, y').format(_selectedInDial),
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedInDial = _selectedInDial.add(Duration(days: 1));
                    _updateTime();
                  });
                },
                child: Icon(
                  CupertinoIcons.chevron_right,
                  size: 14,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ],
          ),
        ),
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

  void _toggleTimeFormat() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _is24HourFormat = !_is24HourFormat;
      prefs.setInt('timeModeOption', _is24HourFormat ? 1 : 0);
      _initializePickerValues();
    });
  }
}
