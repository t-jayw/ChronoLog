// A stateful widget for the display mode section
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/theme_provider.dart';


class DisplayModeSection extends StatefulWidget {
  final WidgetRef ref;
  final ThemeModeOption themeModeOption;
  final Function(ThemeModeOption) updateThemeModeOption;

  const DisplayModeSection({
    Key? key,
    required this.ref,
    required this.themeModeOption,
    required this.updateThemeModeOption,
  }) : super(key: key);

  @override
  _DisplayModeSectionState createState() => _DisplayModeSectionState();
}

class _DisplayModeSectionState extends State<DisplayModeSection> {
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
              'Display:',
              style: TextStyle(
                color: selectedTextColor,
              ),
            ),
          ),
          Expanded(
            child: ToggleButtons(
              children: [
                Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: Text('System')),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: Text('Dark')),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: Text('Light')),
              ],
              isSelected: [
                widget.themeModeOption == ThemeModeOption.system,
                widget.themeModeOption == ThemeModeOption.dark,
                widget.themeModeOption == ThemeModeOption.light,
              ],
              onPressed: (index) {
                widget.updateThemeModeOption(ThemeModeOption.values[index]);
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

