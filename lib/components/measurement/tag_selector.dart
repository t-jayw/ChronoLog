import 'package:flutter/material.dart';

enum Tag {
  dialUp,
  dialDown,
  crownUp,
  crownDown,
  twelveUp,
  threeUp,
  sixUp,
  nineUp,
  justWound,
  overNight,
  onWrist,
}

class TagSelector extends StatelessWidget {
  final void Function(String) onTagSelected;
  final String? selectedTag;

  TagSelector({
    Key? key,
    required this.onTagSelected,
    this.selectedTag,
  }) : super(key: key);

  String enumToString(Tag tag) {
    String text = tag.toString().split('.').last;
    text = text.replaceAllMapped(
        RegExp('([a-z])([A-Z])'), (Match m) => '${m[1]} ${m[2]}');
    text = text
        .split(' ')
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Select a tag',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.tertiary),
                ),
                SizedBox(width: 4),
                Text(
                  '(optional)',
                  style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal, color: Theme.of(context).colorScheme.tertiary),
                ),
              ],
            ),
          ),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 2.0, // gap between adjacent chips
            runSpacing: 0.0, // gap between lines
            children: Tag.values.map((Tag tag) {
              String tagValue = enumToString(tag);
              bool isSelected = selectedTag == tagValue;
              return TextButton(
                onPressed: () => onTagSelected(isSelected ? '' : tagValue),
                child: Text(
                  tagValue,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.inverseSurface ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: isSelected ? Theme.of(context).colorScheme.tertiary : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
