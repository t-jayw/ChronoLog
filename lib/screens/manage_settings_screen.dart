import 'package:chronolog/screens/purchase_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../components/generic_alert.dart';
import '../components/premium/premium_list_item.dart';
import '../components/premium/premium_needed_dialog.dart';
import '../components/user_settings/display_mode_section.dart';
import '../components/user_settings/time_mode_section.dart';
import '../database_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:share_plus/share_plus.dart';

import '../providers/theme_provider.dart';
import '../providers/time_mode_provider.dart';

void _showPremiumNeededDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return PremiumNeededDialogAddWatch();
    },
  );
}

class ManageSettingsScreen extends ConsumerWidget {
  ManageSettingsScreen({Key? key}) : super(key: key);
  final String versionNumber = "1.4.5";

  ThemeModeOption _themeModeOption = ThemeModeOption.system;
  TimeModeOption _timeModeOption = TimeModeOption.twelve;

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
    print(ref.read(themeModeProvider));
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
    print(ref.read(timeModeProvider));
  }

  final DatabaseHelper _db = DatabaseHelper();

  Future<bool> _isPremiumActivated() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();


    return prefs.getBool('isPremiumActive') ??
        false; // default to false if not found
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _loadThemeModeOption(context, ref);
    _themeModeOption = ref.watch(themeModeProvider);

    _loadTimeModeOption(context, ref);
    _timeModeOption = ref.watch(timeModeProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Settings"),
      ),
      body: FutureBuilder<bool>(
        future: _isPremiumActivated(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          bool isPremium = snapshot.data ?? false;

          return Stack(
            children: [
              SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 20),
                      Text(
                        'ChronoLog',
                        style: TextStyle(
                            fontSize: 30,
                            color: Theme.of(context).colorScheme.tertiary),
                      ),
                      Text(
                        'Version: $versionNumber',
                      ),
                      FutureBuilder<String>(
                        future: _db.getDatabaseVersion(),
                        builder: (BuildContext context,
                            AsyncSnapshot<String> snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              'DB version: ${snapshot.data}',
                            );
                          } else if (snapshot.hasError) {
                            return Text(
                              'Error: ${snapshot.error}',
                            );
                          }
                          // By default, show a loading spinner.
                          return CircularProgressIndicator();
                        },
                      ),

                      TimeDisplay(),

                      SizedBox(height: 20),
                      PremiumButton(
                        isPremiumActivated: _isPremiumActivated,
                        onTapPremium: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PurchaseScreen()),
                          );
                        },
                      ),

                      // Expanded(child: PurchaseOptions()),
                      Stack(
                        children: [
                          Column(
                            children: [
                              DisplayModeSection(
                                ref: ref,
                                themeModeOption: _themeModeOption,
                                updateThemeModeOption: (newOption) =>
                                    _updateThemeModeOption(
                                        context, ref, newOption),
                              ),
                              TimeModeSection(
                                ref: ref,
                                timeModeOption: _timeModeOption,
                                updateTimeModeOption: (newOption) =>
                                    _updateTimeModeOption(
                                        context, ref, newOption),
                              ),
                            ],
                          ),

                          //if (!isPremium)
                          if (false)
                            Positioned.fill(
                              child: Material(
                                color: Colors.grey.withOpacity(
                                    0.7), // semi-transparent overlay
                                child: InkWell(
                                  onTap: () {
                                    _showPremiumNeededDialog(context);
                                  },
                                  child: Center(
                                    child: Text(
                                      "",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                  ),
                                ),
                              ),
                            )
                        ],
                      ),
                      SizedBox(height: 20),

                      // Expanded(
                      //     child: Column(
                      //   children: [],
                      // )),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Text(
                              'Made with ⛰️ in Boulder, CO',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Text(
                              '© 2023 Tyler Wood',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class TimeDisplay extends StatefulWidget {
  @override
  _TimeDisplayState createState() => _TimeDisplayState();
}

class _TimeDisplayState extends State<TimeDisplay> {
  late DateTime currentTime;
  final DateFormat formatter = DateFormat('HH:mm:ss');

  @override
  void initState() {
    super.initState();
    currentTime = DateTime.now();
    Future.delayed(Duration(seconds: 1), updateTime);
  }

  void updateTime() {
    if (mounted) {
      // Check if the State object is in a tree.
      setState(() {
        currentTime = DateTime.now();
        Future.delayed(Duration(seconds: 1), updateTime);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      'Current Time: ${formatter.format(currentTime)}',
      style: TextStyle(fontSize: 20),
    );
  }
}

class ListGroup extends StatelessWidget {
  final List<Widget> items;

  ListGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Theme.of(context).colorScheme.primary,
        ),
        child: Column(
          children: items,
        ),
      ),
    );
  }
}

class ManageDataItem extends StatelessWidget {
  final String title;
  final String? bodyText;
  final IconData iconData;
  final bool isLastItem;
  final VoidCallback onTap;

  ManageDataItem({
    required this.title,
    this.bodyText,
    required this.iconData,
    required this.onTap,
    this.isLastItem = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          border: isLastItem
              ? Border()
              : Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.inverseSurface,
                    width: 0.5,
                  ),
                ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(iconData, size: 24.0), // The icon is the first element
            SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // aligns text to the left
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14, // Increased font size
                      color: Theme.of(context).colorScheme.tertiary,
                      fontWeight: FontWeight.bold, // Made it bold for emphasis
                    ),
                  ),
                  if (bodyText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        bodyText!,
                        style:
                            TextStyle(fontSize: 12), // slightly increased size
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
