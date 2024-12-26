import 'package:chronolog/components/primary_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'display_mode_section.dart';
import 'time_mode_section.dart';
import '../../providers/theme_provider.dart';
import '../../providers/time_mode_provider.dart';

class ManageSettingsWidget extends ConsumerWidget {

  ManageSettingsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ThemeModeOption themeModeOption = ref.watch(themeModeProvider);
    TimeModeOption timeModeOption = ref.watch(timeModeProvider);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Manage Settings',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 0,
                onPressed: () => Navigator.of(context).pop(),
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.tertiary,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    CupertinoIcons.xmark,
                    size: 16,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              ),
            ],
          ),
          Divider(
            height: 24,
            thickness: 0.5,
            color: CupertinoColors.separator.resolveFrom(context),
          ),
          DisplayModeSection(
            ref: ref,
            themeModeOption: themeModeOption,
            updateThemeModeOption: (newOption) =>
                _updateThemeModeOption(context, ref, newOption),
          ),
          TimeModeSection(
            ref: ref,
            timeModeOption: timeModeOption,
            updateTimeModeOption: (newOption) =>
                _updateTimeModeOption(context, ref, newOption),
          ),
        ],
      ),
    );
  }

  void _updateThemeModeOption(
      BuildContext context, WidgetRef ref, ThemeModeOption newOption) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('themeModeOption', newOption.index);
    ref.read(themeModeProvider.notifier).state = newOption;
  }

  void _updateTimeModeOption(
      BuildContext context, WidgetRef ref, TimeModeOption newOption) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('timeModeOption', newOption.index);
    ref.read(timeModeProvider.notifier).state = newOption;
  }
}
