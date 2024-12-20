import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTimePicker extends StatefulWidget {
  final ValueChanged<DateTime> onTimeChanged;
  final DateTime initialTime;

  const CustomTimePicker({
    Key? key,
    required this.onTimeChanged,
    required this.initialTime,
  }) : super(key: key);

  @override
  _CustomTimePickerState createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  late int _selectedHour;
  late int _selectedMinute;
  late int _selectedSecond;
  late int _selectedTenthOfSecond;
  bool _isPM = false;

  @override
  void initState() {
    super.initState();
    DateTime currentTime = widget.initialTime;
    _selectedHour = currentTime.hour > 12
        ? currentTime.hour - 12
        : (currentTime.hour == 0 ? 12 : currentTime.hour);
    _isPM = currentTime.hour >= 12;
    _selectedMinute = currentTime.minute;
    _selectedSecond = currentTime.second;
    _selectedTenthOfSecond = currentTime.millisecond ~/ 100;
  }

  void _updateTime() {
    int adjustedHour = _selectedHour == 12 ? 0 : _selectedHour;
    if (_isPM) {
      adjustedHour += 12;
    }
    DateTime now = DateTime.now();
    widget.onTimeChanged(
      DateTime(
          now.year,
          now.month,
          now.day,
          adjustedHour,
          _selectedMinute,
          _selectedSecond,
          _selectedTenthOfSecond * 100 + now.millisecond % 100),
    );
  }

  List<Widget> _generatePickerItems(int count, int offset) {
    return List<Widget>.generate(
        count,
        (index) => Center(
            child: Text('${index + offset}'.padLeft(2,'0'),
                style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onBackground))));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPicker(_selectedHour - 1, 12, 1, (int value) {
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
          _buildPicker(_selectedMinute, 60, 0, (int value) {
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
          _buildPicker(_selectedSecond, 60, 0, (int value) {
            setState(() {
              _selectedSecond = value;
            });
            _updateTime();
          }),
          Text('.',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground)),
          _buildPicker(_selectedTenthOfSecond, 10, 0, (int value) {
            setState(() {
              _selectedTenthOfSecond = value;
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
    );
  }

  Widget _buildPicker(int selectedValue, int numberOfItems, int offset,
      ValueChanged<int> onSelectedItemChanged) {
    return SizedBox(
      height: 150,
      width: 50,
      child: CupertinoPicker(
        diameterRatio: .8,
        itemExtent: 60,
        looping: true,
        selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(),
        onSelectedItemChanged: onSelectedItemChanged,
        children: _generatePickerItems(numberOfItems, offset),
      ),
    );
  }
}
