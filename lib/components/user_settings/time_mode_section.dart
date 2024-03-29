// A stateful widget for the display mode section
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/time_mode_provider.dart';


class TimeModeSection extends StatefulWidget {
  final WidgetRef ref;
  final TimeModeOption timeModeOption;
  final Function(TimeModeOption) updateTimeModeOption;

  const TimeModeSection({
    Key? key,
    required this.ref,
    required this.timeModeOption,
    required this.updateTimeModeOption,
  }) : super(key: key);

  @override
  _TimeModeSectionState createState() => _TimeModeSectionState();
}

class _TimeModeSectionState extends State<TimeModeSection> {
  @override
  Widget build(BuildContext context) {
    // Use theme-dependent colors
    Color backgroundColor = Theme.of(context).colorScheme.surface;
    Color borderColor = Theme.of(context).colorScheme.onSurface;
    // Ensures text color contrasts well with the background in both light and dark themes
    Color textColor = Theme.of(context).colorScheme.tertiary;
    // Adjusts the color for selected text to ensure it is readable in both light and dark themes
    Color selectedTextColor = Theme.of(context).colorScheme.onBackground;
    Color buttonColor = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Text(
              'Time Mode:',
              style: TextStyle(
                color: selectedTextColor,
              ),
            ),
          ),
          Expanded(
            child: ToggleButtons(
              children: [
                Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: Text('12 hr')),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: Text('24 hr')),
              ],
              isSelected: [
                widget.timeModeOption == TimeModeOption.twelve,
                widget.timeModeOption == TimeModeOption.military,
              ],
              onPressed: (index) {
                widget.updateTimeModeOption(TimeModeOption.values[index]);
              },
              borderRadius: BorderRadius.circular(8),
              color: textColor,
              selectedColor: selectedTextColor,
              fillColor: buttonColor,
              constraints: BoxConstraints(minWidth: 40, minHeight: 30.0),
            ),
          ),
        ],
      ),
    );
  }
}

