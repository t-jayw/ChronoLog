import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:intl/intl.dart';
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
    _minutePickerController.dispose();
    _hourPickerController.dispose();
    _secondPickerController.dispose();
    super.dispose();
  }

  void _loadTimeModePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Default to system setting if no preference is set
      _is24HourFormat = prefs.getInt('timeModeOption') == 1;
      _initializePickerValues();
    });
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

    // Keep the date from _selectedInDial
    DateTime currentDate = _selectedInDial;
    _selectedInDial = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
      adjustedHour,
      _selectedMinute,
      _selectedSecond,
      0,
    );

    widget.onTimeChanged(_selectedInDial);
  }

  // ------------------------------------------------------------------
  //  ROLLOVER HANDLERS
  // ------------------------------------------------------------------

  /// Handle second changes and detect rollover into next minute.
  void _handleSecondChange(int newSeconds) {
    setState(() {
      // If the old second was e.g. 59 and the new second is near 0, that’s a forward rollover
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

  /// Handle minute changes and detect rollover into next/previous hour.
  /// (Similar logic to _handleSecondChange, but for minutes.)
  ///
  /// NEW OR MODIFIED
  void _handleMinuteChange(int newMinute) {
    setState(() {
      // If old was 59 and new is near 0, forward rollover
      bool incrementHour = (_selectedMinute == 59 && newMinute == 0);
      // If old was 0 and new is near 59, backward rollover
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

  /// Handle hour changes and detect rollover into next/previous day.
  ///
  /// * For 24-hour format, rolling 23→0 increments day, and 0→23 decrements day.
  /// * For 12-hour format, you’ll likely want to toggle AM/PM on crossing
  ///   boundaries, and handle midnight/day rollover if crossing from 11:59 PM
  ///   to 12:00 AM, etc.  (Below is a simplified example.)
  ///
  /// NEW OR MODIFIED
  void _handleHourChange(int newHourIndex) {
    setState(() {
      // oldHour (0..23 in 24h, or 1..12 in 12h)
      int oldHour = _selectedHour;

      if (_is24HourFormat) {
        // In 24-hour format, newHourIndex is 0..23 directly
        _selectedHour = newHourIndex;

        bool isRolloverForward = (oldHour == 23 && _selectedHour == 0);
        bool isRolloverBackward = (oldHour == 0 && _selectedHour == 23);

        // If rolling from 23->0, increment day
        if (isRolloverForward) {
          print('Increment day');
          _selectedInDial = _selectedInDial.add(Duration(days: 1));
        }
        // If rolling from 0->23, decrement day
        else if (isRolloverBackward) {
          print('Decrement day');
          _selectedInDial = _selectedInDial.subtract(Duration(days: 1));
        }
      } else {
        // In 12-hour format, newHourIndex is 0..11, but the displayed hour is (newHourIndex + 1)
        int new12Hour = newHourIndex + 1; // now in [1..12]
        // Toggle AM/PM if crossing 11->12 or 12->1
        bool crossingBoundary =
            ((oldHour == 11 && new12Hour == 12) ||
                (oldHour == 12 && new12Hour == 11));

        if (crossingBoundary) {
          // Switch AM<->PM
          _isPM = !_isPM;
        }

        // (Simple approach to detect day rollover: if we go from 11 PM -> 12 AM)
        bool wasMidnight = (oldHour == 11 && _isPM == false); // 11 AM => 12 PM is not day rollover
        bool isNowMidnight = (new12Hour == 12 && _isPM == false); // 12 AM
        // If we just toggled from 11:xx PM to 12:xx AM, then day increments
        // (This is a rough demonstration. In practice, you'd want to be sure you're specifically crossing from 11:59 PM to 12:00 AM, etc.)
        if (wasMidnight && isNowMidnight) {
          print('Day rollover at midnight in 12-hour mode');
          _selectedInDial = _selectedInDial.add(Duration(days: 1));
        }

        // Finally, update our selectedHour in 12-hour format
        _selectedHour = new12Hour;
      }

      _updateTime();
    });
  }

  // ------------------------------------------------------------------
  //  Increment/decrement methods used in minute/second hand rollover
  // ------------------------------------------------------------------

  void _incrementHour() {
    if (_is24HourFormat) {
      _selectedHour = (_selectedHour + 1) % 24;

      // NEW OR MODIFIED: check if we’ve just rolled 23 -> 0
      if (_selectedHour == 0) {
        print("Hour rolled over forward, increment day");
        _selectedInDial = _selectedInDial.add(Duration(days: 1));
      }

      _hourPickerController.jumpToItem(_selectedHour);
    } else {
      // 12-hour logic
      if (_selectedHour == 12) {
        _selectedHour = 1;
        _isPM = !_isPM;
        // If we toggled from 12:xx PM to 1:xx PM, that’s not day rollover, but
        // from 12:xx AM to 1:xx AM might or might not be day rollover
        // (depending on whether it was 12:xx AM midnight).
      } else {
        _selectedHour++;
        if (_selectedHour > 12) {
          _selectedHour = 1;
        }
        // If we crossed from 11->12, toggle
        if (_selectedHour == 12) {
          _isPM = !_isPM;
          // Possibly day rollover if it’s turning 12:xx AM
          if (!_isPM) {
            // 12 AM means we just incremented day from previous day
            print("Increment day at midnight (12 AM).");
            _selectedInDial = _selectedInDial.add(Duration(days: 1));
          }
        }
      }
      _hourPickerController.jumpToItem(_selectedHour - 1);
    }
    _updateTime();
    setState(() {});
  }

  void _decrementHour() {
    if (_is24HourFormat) {
      _selectedHour = (_selectedHour - 1) < 0 ? 23 : _selectedHour - 1;

      // NEW OR MODIFIED: check if we’ve just rolled 0 -> 23
      if (_selectedHour == 23) {
        print("Hour rolled over backward, decrement day");
        _selectedInDial = _selectedInDial.subtract(Duration(days: 1));
      }

      _hourPickerController.jumpToItem(_selectedHour);
    } else {
      // 12-hour logic
      if (_selectedHour == 12) {
        _selectedHour = 11;
        _isPM = !_isPM;
        // Possibly day rollover if we’re crossing from 12 AM to 11 PM
        // (this can get tricky to handle precisely).
      } else if (_selectedHour == 1) {
        _selectedHour = 12;
        _isPM = !_isPM;
        // If we just jumped from 1:xx AM to 12:xx AM, that might be
        // going backward across midnight → day - 1
        if (!_isPM) {
          // 12 AM after going backwards means we’re now on the previous day
          print("Decrement day at midnight (12 AM).");
          _selectedInDial = _selectedInDial.subtract(Duration(days: 1));
        }
      } else {
        _selectedHour--;
        if (_selectedHour < 1) {
          _selectedHour = 12;
        }
      }
      _hourPickerController.jumpToItem(_selectedHour - 1);
    }

    _updateTime();
    setState(() {});
  }

  void _incrementMinute() {
    _selectedMinute = (_selectedMinute + 1) % 60;
    if (_selectedMinute == 0) {
      // If we just rolled 59 -> 0, increment hour
      _incrementHour();
    }
    _minutePickerController.jumpToItem(_selectedMinute);
    _updateTime();
  }

  void _decrementMinute() {
    if (_selectedMinute == 0) {
      _selectedMinute = 59;
      // If we just rolled 0 -> 59 backwards, decrement hour
      _decrementHour();
    } else {
      _selectedMinute--;
    }
    _minutePickerController.jumpToItem(_selectedMinute);
    _updateTime();
  }

  // ------------------------------------------------------------------
  //  UI
  // ------------------------------------------------------------------

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
                  _handleHourChange, // <--- Hook up the hour handler
                  scrollController: _hourPickerController,
                  loopingAllowed: true,
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

            // Minute Picker
            Column(
              children: [
                Text('M', style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.tertiary)),
                _buildPicker(
                  _selectedMinute,
                  60,
                  0,
                  _handleMinuteChange, // <--- Hook up the new minute handler
                  scrollController: _minutePickerController,
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
                    _handleSecondChange, // <--- Already uses second handler
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

            // AM/PM indicator (12-hour)
            if (!_is24HourFormat)
              Padding(
                padding: EdgeInsets.only(left: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('', style: TextStyle(fontSize: 10)),
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

  Widget _buildDebugPanel() {
    if (!kDebugMode) return SizedBox.shrink();

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
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _toggleTimeFormat,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  SizedBox(width: 8),
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
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleTimeFormat() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _is24HourFormat = !_is24HourFormat;
      // Save the preference: 1 for 24h, 0 for 12h
      prefs.setInt('timeModeOption', _is24HourFormat ? 1 : 0);
      _initializePickerValues();
    });
  }
}
