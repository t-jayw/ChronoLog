import 'package:chronolog/components/primary_button.dart';
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
    _loadThemeModeOption(context, ref);
    ThemeModeOption themeModeOption = ref.watch(themeModeProvider);

    _loadTimeModeOption(context, ref);
    TimeModeOption timeModeOption = ref.watch(timeModeProvider);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context)
            .dialogBackgroundColor, // Set the background color here
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Manage Settings',
            style: TextStyle(
                fontSize: 30, color: Theme.of(context).colorScheme.tertiary),
          ),
          SizedBox(height: 20),
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
          SizedBox(height: 20),
          PrimaryButton(
            child: Text(
              "Close",
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _loadThemeModeOption(BuildContext context, WidgetRef ref) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt('themeModeOption') ?? 0;
    ref.read(themeModeProvider.notifier).state =
        ThemeModeOption.values[themeModeIndex];
  }

  void _updateThemeModeOption(
      BuildContext context, WidgetRef ref, ThemeModeOption newOption) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('themeModeOption', newOption.index);
    ref.read(themeModeProvider.notifier).state = newOption;
  }

  void _loadTimeModeOption(BuildContext context, WidgetRef ref) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final timeModeIndex = prefs.getInt('timeModeOption') ?? 0;
    ref.read(timeModeProvider.notifier).state =
        TimeModeOption.values[timeModeIndex];
  }

  void _updateTimeModeOption(
      BuildContext context, WidgetRef ref, TimeModeOption newOption) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('timeModeOption', newOption.index);
    ref.read(timeModeProvider.notifier).state = newOption;
  }
}
