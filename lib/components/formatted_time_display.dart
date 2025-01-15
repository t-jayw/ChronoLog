import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/time_mode_provider.dart';

class FormattedTimeDisplay extends ConsumerWidget {
  final DateTime dateTime;
  final bool showMilliseconds;
  final TextStyle? style;

  const FormattedTimeDisplay({
    Key? key,
    required this.dateTime,
    this.showMilliseconds = true,
    this.style,
  }) : super(key: key);

  String _formatDate() {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  String _formatTime(bool use24HourFormat) {
    final pattern = use24HourFormat ? 'HH:mm:ss' : 'hh:mm:ss';
    final amPmPattern = use24HourFormat ? '' : ' a';
    final formattedTime = DateFormat(pattern).format(dateTime);
    final amPm = use24HourFormat ? '' : DateFormat(amPmPattern).format(dateTime);
    
    return showMilliseconds 
        ? '$formattedTime.${(dateTime.millisecond / 100).floor()}$amPm'
        : '$formattedTime$amPm';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeModeOption = ref.watch(timeModeProvider);
    final use24HourFormat = timeModeOption == TimeModeOption.military;
    
    final defaultStyle = style ?? Theme.of(context).textTheme.bodyMedium;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          _formatDate(),
          style: defaultStyle?.copyWith(
            fontSize: defaultStyle.fontSize! * 0.8,
            color: defaultStyle.color?.withOpacity(0.7),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _formatTime(use24HourFormat),
          style: defaultStyle,
        ),
      ],
    );
  }
}