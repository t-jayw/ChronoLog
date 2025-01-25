import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

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
  late int _selectedHour;   // If 24-hour mode: 0..23; if 12-hour: 1..12
  late int _selectedMinute;
  late int _selectedSecond;
  late int _selectedTenthOfSecond; // Only used in Image mode
  bool _isPM = false;              // Relevant for 12-hour mode
  bool _is24HourFormat = false;    // Default to 12-hour
  bool _isLoading = true;

  late FixedExtentScrollController _hourPickerController;
  late FixedExtentScrollController _minutePickerController;
  late FixedExtentScrollController _secondPickerController;

  late DateTime _deviceCurrentTime;
  late DateTime _selectedInDial;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    // Use initialTime or deviceTime+offset
    _deviceCurrentTime = DateTime.now();
    _selectedInDial = widget.initialTime ?? _deviceCurrentTime.add(widget.initialOffset);

    // Update device time every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _deviceCurrentTime = DateTime.now();
      });
    });

    _loadTimeModePreference();

    // Initialize the controllers to the "minute" and "hour" from _selectedInDial
    _minutePickerController =
        FixedExtentScrollController(initialItem: _selectedInDial.minute);
    _hourPickerController =
        FixedExtentScrollController(initialItem: _selectedInDial.hour);
  }

  @override
  void dispose() {
    _timer.cancel();
    _minutePickerController.dispose();
    _hourPickerController.dispose();
    _secondPickerController.dispose();
    super.dispose();
  }

  // Load 12h/24h preference
  Future<void> _loadTimeModePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // timeModeOption = 1 => 24-hour; 0 => 12-hour
      _is24HourFormat = (prefs.getInt('timeModeOption') == 1);
      _initializePickerValues();
    });
  }

  void _initializePickerValues() {
    final hour24 = _selectedInDial.hour;
    _selectedMinute = _selectedInDial.minute;
    _selectedSecond = _selectedInDial.second;
    _selectedTenthOfSecond = _selectedInDial.millisecond ~/ 100;

    if (_is24HourFormat) {
      // 24-hour dial: 0..23
      _selectedHour = hour24;
    } else {
      // Convert from 24-hour to 12-hour
      if (hour24 == 0) {
        _selectedHour = 12; // 12 AM
        _isPM = false;
      } else if (hour24 == 12) {
        _selectedHour = 12; // 12 PM
        _isPM = true;
      } else if (hour24 > 12) {
        _selectedHour = hour24 - 12; // e.g. 13 -> 1 PM
        _isPM = true;
      } else {
        _selectedHour = hour24; // 1..11 => AM
        _isPM = false;
      }
    }

    // Rebuild the hour & minute controllers
    final hourItem = _is24HourFormat
        ? _selectedHour         // 0..23
        : (_selectedHour - 1);  // 1..12 => index 0..11 in CupertinoPicker
    _hourPickerController = FixedExtentScrollController(initialItem: hourItem);

    _minutePickerController =
        FixedExtentScrollController(initialItem: _selectedMinute);

    _secondPickerController =
        FixedExtentScrollController(initialItem: _selectedSecond);

    setState(() => _isLoading = false);
  }

  // ---------------------------------------------------------------------------
  //   KEY CHANGE: In _updateTime(), choose the date that keeps us closest
  //               to the device time, so crossing midnight doesn't jump 24h.
  // ---------------------------------------------------------------------------
  void _updateTime() {
    // Convert 12-hour selection to 24-hour if necessary
    int finalHour;
    if (_is24HourFormat) {
      finalHour = _selectedHour; // 0..23 directly
    } else {
      // 12-hour => 24-hour
      if (_selectedHour == 12) {
        finalHour = _isPM ? 12 : 0; // 12 PM => 12, 12 AM => 0
      } else {
        finalHour = _isPM ? _selectedHour + 12 : _selectedHour;
      }
    }

    // 1) First, assume the user is picking a time on _selectedInDial.day
    DateTime newTimeSameDay = DateTime(
      _selectedInDial.year,
      _selectedInDial.month,
      _selectedInDial.day,
      finalHour,
      _selectedMinute,
      _selectedSecond,
      _selectedTenthOfSecond * 100,
    );

    // 2) Compare to device time
    final diff = newTimeSameDay.difference(_deviceCurrentTime);

    // 3) If difference is outside ±12 hours, shift day by ±1 so that user stays near device time
    const halfDay = Duration(hours: 12);

    if (diff > halfDay) {
      // Means newTimeSameDay is more than +12h ahead, so subtract 1 day
      newTimeSameDay = newTimeSameDay.subtract(const Duration(days: 1));
    } else if (diff < -halfDay) {
      // Means newTimeSameDay is more than -12h behind, so add 1 day
      newTimeSameDay = newTimeSameDay.add(const Duration(days: 1));
    }

    _selectedInDial = newTimeSameDay;
    widget.onTimeChanged(_selectedInDial);
  }

  // ---------------------------------------------------------------------------
  //   PICKER CHANGE HANDLERS
  // ---------------------------------------------------------------------------

  /// Called when user scrolls the hour wheel.
  /// * 24-hour: newHourIndex = 0..23
  /// * 12-hour: newHourIndex = 0..11 => displayed hour is (newHourIndex+1)
  void _handleHourChange(int newHourIndex) {
    setState(() {
      int oldHour = _selectedHour;
      if (_is24HourFormat) {
        _selectedHour = newHourIndex; // 0..23
      } else {
        int new12Hour = newHourIndex + 1; // 1..12

        // Check crossing 11→12 or 12→11 => flip AM/PM
        bool crossingBoundary = (oldHour == 11 && new12Hour == 12)
                             || (oldHour == 12 && new12Hour == 11);
        if (crossingBoundary) {
          _isPM = !_isPM;
        }

        _selectedHour = new12Hour;
      }
      _updateTime();
    });
  }

  /// Called when user scrolls the minute wheel.
  /// If we cross 59→0 or 0→59, we increment/decrement hour.
  void _handleMinuteChange(int newMinute) {
    setState(() {
      bool incrementHour = (_selectedMinute == 59 && newMinute == 0);
      bool decrementHour = (_selectedMinute == 0 && newMinute == 59);

      _selectedMinute = newMinute;

      if (incrementHour) {
        _incrementHour();
      } else if (decrementHour) {
        _decrementHour();
      }

      _updateTime();
    });
  }

  /// Called when user scrolls the second wheel.
  /// If we cross 59→0 or 0→59, we increment/decrement minute.
  void _handleSecondChange(int newSecond) {
    setState(() {
      bool incrementMinute = (_selectedSecond == 59 && newSecond == 0);
      bool decrementMinute = (_selectedSecond == 0 && newSecond == 59);

      _selectedSecond = newSecond;

      if (incrementMinute) {
        _incrementMinute();
      } else if (decrementMinute) {
        _decrementMinute();
      }

      _updateTime();
    });
  }

  // ---------------------------------------------------------------------------
  //   HOUR/MINUTE INCREMENT/DECREMENT (used by rollover)
  // ---------------------------------------------------------------------------

  void _incrementHour() {
    if (_is24HourFormat) {
      _selectedHour = (_selectedHour + 1) % 24;
      _hourPickerController.jumpToItem(_selectedHour);
    } else {
      // 12-hour
      if (_selectedHour == 11) {
        // 11 -> 12 => flip
        _selectedHour = 12;
        _isPM = !_isPM;
      } else if (_selectedHour == 12) {
        // 12 -> 1 => same AM/PM
        _selectedHour = 1;
      } else {
        _selectedHour++;
      }
      _hourPickerController.jumpToItem(_selectedHour - 1);
    }
  }

  void _decrementHour() {
    if (_is24HourFormat) {
      if (_selectedHour == 0) {
        _selectedHour = 23;
      } else {
        _selectedHour--;
      }
      _hourPickerController.jumpToItem(_selectedHour);
    } else {
      // 12-hour
      if (_selectedHour == 12) {
        // 12 -> 11 => flip
        _selectedHour = 11;
        _isPM = !_isPM;
      } else if (_selectedHour == 1) {
        // 1 -> 12 => same AM/PM
        _selectedHour = 12;
      } else {
        _selectedHour--;
      }
      _hourPickerController.jumpToItem(_selectedHour - 1);
    }
  }

  void _incrementMinute() {
    _selectedMinute = (_selectedMinute + 1) % 60;
    if (_selectedMinute == 0) {
      _incrementHour();
    }
    _minutePickerController.jumpToItem(_selectedMinute);
  }

  void _decrementMinute() {
    if (_selectedMinute == 0) {
      _selectedMinute = 59;
      _decrementHour();
    } else {
      _selectedMinute--;
    }
    _minutePickerController.jumpToItem(_selectedMinute);
  }

  // ---------------------------------------------------------------------------
  //   WIDGET BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CircularProgressIndicator();
    }
    return Column(
      children: [
        _buildDebugPanel(),
        _buildTimePickersRow(),
        _buildDateSelectorRow(context),
      ],
    );
  }

  Widget _buildDebugPanel() {
    // Hide debug panel in release mode
    if (!kDebugMode) return const SizedBox.shrink();
    final difference = _selectedInDial.difference(_deviceCurrentTime);
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.tertiary),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Device Time: $_deviceCurrentTime'),
          Text('Selected Time: $_selectedInDial'),
          Text('Difference: ${difference.inSeconds} seconds'),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _toggleTimeFormat,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.time,
                    size: 20,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _is24HourFormat ? 'Switch to 12h' : 'Switch to 24h',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickersRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Hour
        Column(
          children: [
            Text(
              'H',
              style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.tertiary),
            ),
            _buildPicker(
              _selectedHour,
              _is24HourFormat ? 24 : 12,
              _is24HourFormat ? 0 : 1,
              _handleHourChange,
              scrollController: _hourPickerController,
            ),
          ],
        ),
        // Separator
        Column(
          children: [
            const SizedBox(height: 10),
            Text(
              ':',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ],
        ),
        // Minute
        Column(
          children: [
            Text(
              'M',
              style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.tertiary),
            ),
            _buildPicker(
              _selectedMinute,
              60,
              0,
              _handleMinuteChange,
              scrollController: _minutePickerController,
            ),
          ],
        ),
        // Separator
        Column(
          children: [
            const SizedBox(height: 10),
            Text(
              ':',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ],
        ),
        // Second (tap/image modes)
        if (widget.mode == TimePickerMode.tap || widget.mode == TimePickerMode.image)
          Column(
            children: [
              Text(
                'S',
                style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.tertiary),
              ),
              _buildPicker(
                _selectedSecond,
                60,
                0,
                _handleSecondChange,
                scrollController: _secondPickerController,
              ),
            ],
          ),
        // Tenth-of-second (image mode only)
        if (widget.mode == TimePickerMode.image) ...[
          Column(
            children: [
              const SizedBox(height: 10),
              Text(
                '.',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            ],
          ),
          Column(
            children: [
              const SizedBox(height: 10),
              _buildPicker(
                _selectedTenthOfSecond,
                10,
                0,
                (val) {
                  setState(() {
                    _selectedTenthOfSecond = val;
                    _updateTime();
                  });
                },
                isSubsecond: true,
              ),
            ],
          ),
        ],
        // AM/PM in 12-hour mode
        if (!_is24HourFormat)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
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
    );
  }

  Widget _buildDateSelectorRow(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrement date
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedInDial = _selectedInDial.subtract(const Duration(days: 1));
                widget.onTimeChanged(_selectedInDial);
              });
            },
            child: Icon(
              CupertinoIcons.chevron_left,
              size: 14,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              DateFormat('MMM d, y').format(_selectedInDial),
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ),
          // Increment date
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedInDial = _selectedInDial.add(const Duration(days: 1));
                widget.onTimeChanged(_selectedInDial);
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
    );
  }

  /// A generic Cupertino picker builder
  Widget _buildPicker(
    int selectedValue,
    int count,
    int offset,
    ValueChanged<int> onSelectedItemChanged, {
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
        scrollController: scrollController ??
            FixedExtentScrollController(initialItem: selectedValue - offset),
        onSelectedItemChanged: onSelectedItemChanged,
        children: List<Widget>.generate(count, (index) {
          int displayVal = index + offset; // e.g. 0..23 or 1..12 or 0..59
          return Center(
            child: Text(
              isSubsecond
                  ? '$displayVal'
                  : displayVal.toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          );
        }),
      ),
    );
  }

  // Toggle 12/24-hour mode, saving preference
  void _toggleTimeFormat() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _is24HourFormat = !_is24HourFormat;
      prefs.setInt('timeModeOption', _is24HourFormat ? 1 : 0);
      _initializePickerValues();
    });
  }
}
