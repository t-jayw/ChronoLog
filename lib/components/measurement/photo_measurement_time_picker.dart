import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/time_mode_provider.dart';

class CustomTimePicker extends ConsumerWidget {
  final ValueChanged<DateTime> onTimeChanged;
  final DateTime initialTime;

  const CustomTimePicker({
    Key? key,
    required this.onTimeChanged,
    required this.initialTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeMode = ref.watch(timeModeProvider);
    
    return _CustomTimePickerContent(
      onTimeChanged: onTimeChanged,
      initialTime: initialTime,
      timeMode: timeMode,
    );
  }
}

class _CustomTimePickerContent extends StatefulWidget {
  final ValueChanged<DateTime> onTimeChanged;
  final DateTime initialTime;
  final TimeModeOption timeMode;

  const _CustomTimePickerContent({
    Key? key,
    required this.onTimeChanged,
    required this.initialTime,
    required this.timeMode,
  }) : super(key: key);

  @override
  _CustomTimePickerContentState createState() => _CustomTimePickerContentState();
}

class _CustomTimePickerContentState extends State<_CustomTimePickerContent> {
  late int _selectedHour;
  late int _selectedMinute;
  late int _selectedSecond;
  late int _selectedTenthOfSecond;
  late bool _isPM;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _secondController;
  late FixedExtentScrollController _tenthController;

  @override
  void initState() {
    super.initState();
    _initializeTime(widget.initialTime);
    _hourController = FixedExtentScrollController(initialItem: _selectedHour - 1);
    _minuteController = FixedExtentScrollController(initialItem: _selectedMinute);
    _secondController = FixedExtentScrollController(initialItem: _selectedSecond);
    _tenthController = FixedExtentScrollController(initialItem: _selectedTenthOfSecond);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _secondController.dispose();
    _tenthController.dispose();
    super.dispose();
  }

  void _initializeTime(DateTime time) {
    if (widget.timeMode == TimeModeOption.military) {
      _selectedHour = time.hour;
      _isPM = false;
    } else {
      _selectedHour = time.hour % 12;
      if (_selectedHour == 0) _selectedHour = 12;
      _isPM = time.hour >= 12;
    }
    
    _selectedMinute = time.minute;
    _selectedSecond = time.second;
    _selectedTenthOfSecond = time.millisecond ~/ 100;
  }

  void _updateTime() {
    int adjustedHour;
    if (widget.timeMode == TimeModeOption.military) {
      adjustedHour = _selectedHour;
    } else {
      adjustedHour = _selectedHour == 12 ? 0 : _selectedHour;
      if (_isPM) {
        adjustedHour += 12;
      }
    }

    DateTime original = widget.initialTime;

    widget.onTimeChanged(
      DateTime(
        original.year,
        original.month,
        original.day,
        adjustedHour,
        _selectedMinute,
        _selectedSecond,
        _selectedTenthOfSecond * 100,
      ),
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
          _buildPicker(
            widget.timeMode == TimeModeOption.military ? _selectedHour : _selectedHour - 1,
            widget.timeMode == TimeModeOption.military ? 24 : 12,
            widget.timeMode == TimeModeOption.military ? 0 : 1,
            (int value) {
              setState(() {
                _selectedHour = widget.timeMode == TimeModeOption.military ? value : value + 1;
              });
              _updateTime();
            }
          ),
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
          if (widget.timeMode == TimeModeOption.twelve)
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
    final controller = FixedExtentScrollController(initialItem: selectedValue);
    
    return SizedBox(
      height: 150,
      width: 50,
      child: CupertinoPicker.builder(
        scrollController: controller,
        diameterRatio: .8,
        itemExtent: 60,
        useMagnifier: true,
        selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(),
        onSelectedItemChanged: onSelectedItemChanged,
        itemBuilder: (context, index) => Center(
          child: Text(
            '${index + offset}'.padLeft(2, '0'),
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.onBackground
            )
          )
        ),
        childCount: numberOfItems,
      ),
    );
  }
}
