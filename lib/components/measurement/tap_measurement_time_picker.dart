import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TapMeasurementTimePicker extends StatefulWidget {
  final ValueChanged<DateTime> onTimeChanged;
  final DateTime initialTime;

  const TapMeasurementTimePicker({
    Key? key,
    required this.onTimeChanged,
    required this.initialTime,
  }) : super(key: key);

  @override
  _TapMeasurementTimePicker createState() => _TapMeasurementTimePicker();
}

class _TapMeasurementTimePicker extends State<TapMeasurementTimePicker> {
  late int _selectedHour;
  late int _selectedMinute;
  late int _selectedSecond;
  bool _isPM = false;

  @override
  void initState() {
    super.initState();

    DateTime currentTime = widget.initialTime;
    _selectedHour = currentTime.hour > 12
        ? currentTime.hour - 12
        : (currentTime.hour == 0 ? 12 : currentTime.hour); // Adjust for 12 AM
    _isPM = currentTime.hour >= 12;
    _selectedMinute = currentTime.minute;
    _selectedSecond = (currentTime.second ~/ 5);

    //_updateTime();
  }

  void _updateTime() {
    int adjustedHour;
    if (_isPM) {
      adjustedHour = _selectedHour == 12 ? 12 : _selectedHour + 12;
    } else {
      adjustedHour = _selectedHour == 12 ? 0 : _selectedHour;
    }

    widget.onTimeChanged(
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day,
          adjustedHour, _selectedMinute, _selectedSecond * 5),
    );
  }

  List<Widget> _generatePickerItems(int count, int offset, int multiplier) {
    return List<Widget>.generate(
        count,
        (index) => Center(
            child: Text('${(index + offset) * multiplier}'.padLeft(2, '0'),
                style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onBackground))));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
              "Set the picker to a time in the future. \nTap the button when your watch reaches that time.",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface, fontSize: 18),
              textAlign: TextAlign.center),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPicker(_selectedHour - 1, 12, 1, 1, (int value) {
              setState(() {
                _selectedHour = value + 1;
              });
              _updateTime();
            }),
            Text(':',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground)),
            _buildPicker(_selectedMinute, 60, 0, 1, (int value) {
              setState(() {
                _selectedMinute = value;
              });
              _updateTime();
            }),
            Text(':',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground)),
            _buildPicker(_selectedSecond, 12, 0, 5, (int value) {
              setState(() {
                _selectedSecond = value;
              });
              _updateTime();
            }),
            Transform.scale(
              scale: 0.8,
              child: ToggleButtons(
                color: Theme.of(context).colorScheme.onBackground,
                selectedColor: Theme.of(context).colorScheme.tertiary,
                fillColor: Theme.of(context).colorScheme.primary,
                borderColor: Theme.of(context).colorScheme.onBackground,
                borderRadius: BorderRadius.circular(10),
                onPressed: (int index) {
                  setState(() {
                    _isPM = index == 1;
                    _updateTime();
                  });
                },
                isSelected: [_isPM == false, _isPM == true],
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'AM',
                      style: TextStyle(
                        fontSize: _isPM ? 16 : 20,
                        fontWeight: _isPM ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'PM',
                      style: TextStyle(
                        fontSize: _isPM ? 20 : 16,
                        fontWeight: _isPM ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPicker(int selectedValue, int numberOfItems, int offset,
      int multiplier, ValueChanged<int> onSelectedItemChanged) {
    return SizedBox(
      height: 150,
      width: 50,
      child: CupertinoPicker(
        diameterRatio: .8,
        itemExtent: 60,
        looping: true,
        selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(),
        onSelectedItemChanged: onSelectedItemChanged,
        scrollController:
            FixedExtentScrollController(initialItem: selectedValue),
        children: _generatePickerItems(numberOfItems, offset, multiplier),
      ),
    );
  }
}
