import 'package:chronolog/main.dart';
import 'package:chronolog/screens/manage_data_screen.dart';
import 'package:chronolog/screens/purchase_screen.dart';
import 'package:chronolog/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../components/premium/premium_list_item.dart';
import '../database_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:posthog_flutter/posthog_flutter.dart';

import '../providers/theme_provider.dart';

enum ThemeModeOption { system, dark, light }

void sendMailWithCSV(String csv) async {
  final Uri mailUri = Uri(
    scheme: 'mailto',
    path: '',
    queryParameters: {
      'subject': 'Exported CSV file',
      'body': csv,
    },
  );

  if (await canLaunch(mailUri.toString())) {
    await launch(mailUri.toString());
  } else {
    throw 'Could not launch ${mailUri.toString()}';
  }
}

void sendMailWithFeedback() async {
  final Uri mailUri = Uri(
    scheme: 'mailto',
    path: 'tylerjaywood@gmail.com',
    queryParameters: {
      'subject': 'ChronoLog feedback!',
    },
  );

  if (await canLaunch(mailUri.toString())) {
    await launch(mailUri.toString());
  } else {
    throw 'Could not launch ${mailUri.toString()}';
  }
}

class InfoPage extends ConsumerWidget {
  InfoPage({Key? key}) : super(key: key);

  final String versionNumber = "1.4.2";
  // replace with actual value
  ThemeModeOption _themeModeOption = ThemeModeOption.system;

  final DatabaseHelper _db = DatabaseHelper();

  Future<bool> _isPremiumActivated() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Print all shared prefs values
    Set<String> keys = prefs.getKeys();
    for (String key in keys) {
      var value = prefs.get(key);
      print('$key: $value');
    }

    return prefs.getBool('isPremiumActive') ??
        false; // default to false if not found
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
    print(ref.read(themeModeProvider));
  }

  Future<int> _getOpenCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('openCount') ?? 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    Posthog().screen(
      screenName: 'info_page',
    );

    _loadThemeModeOption(context, ref);
    _themeModeOption = ref.watch(themeModeProvider);
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20),
            Text(
              'ChronoLog',
              style: TextStyle(
                  fontSize: 30, color: Theme.of(context).colorScheme.tertiary),
            ),
            Text(
              'Version: $versionNumber',
            ),
            FutureBuilder<String>(
              future: _db.getDatabaseVersion(),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
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
                  MaterialPageRoute(builder: (context) => PurchaseScreen()),
                );
              },
            ),

            // Expanded(child: PurchaseOptions()),
            ListGroup(
              items: [
                ListItem(
                  title: 'Show Welcome Screen',
                  iconData: Icons.watch_later,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WelcomeScreen()),
                    );
                  },
                ),

                // ListItem(
                //   title: 'Purchase Premium',
                //   iconData: Icons.star_border,
                //    onTap: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(builder: (context) => PurchaseScreen()),
                //     );
                //   },
                // ),

                ListItem(
                  title: 'Website',
                  iconData: Icons.web_asset,
                  onTap: () async {
                    const url = 'https://www.tylerjaywood.com/chronolog';
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                ),
                ListItem(
                  title: 'Send Me Feedback!',
                  iconData: Icons.email,
                  onTap: () async {
                    sendMailWithFeedback();
                  },
                ),

                ListItem(
                  title: 'Review on App Store',
                  iconData: Icons.star_border,
                  onTap: () async {
                    const url =
                        'https://apps.apple.com/us/app/apple-store/6452083510';
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                ),

                ListItem(
                  title: 'Manage Data',
                  iconData: Icons.dataset,
                  onTap: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ManageDataScreen()),
                    );
                  },
                  isLastItem: true,
                ),
                // Add more items as needed
              ],
            ),
            SizedBox(height: 20),
            Container(
              child: Column(
                children: [
                  Text('Display Mode',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inverseSurface)),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ToggleButtons(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('System'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Dark'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Light'),
                        ),
                      ],
                      isSelected: [
                        _themeModeOption == ThemeModeOption.system,
                        _themeModeOption == ThemeModeOption.dark,
                        _themeModeOption == ThemeModeOption.light,
                      ],
                      onPressed: (index) {
                        _updateThemeModeOption(
                            context, ref, ThemeModeOption.values[index]);
                      },
                      borderRadius: BorderRadius.circular(16),
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface, // This will be the color of the unselected buttons
                      selectedColor: Theme.of(context)
                          .colorScheme
                          .tertiary, // This will be the color of the selected button
                    ),
                  ),
                ],
              ),
            ),
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
  final List<ListItem> items;

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

class ListItem extends StatelessWidget {
  final String title;
  final IconData iconData;
  final bool isLastItem;
  final VoidCallback onTap;

  ListItem(
      {required this.title,
      required this.iconData,
      required this.onTap,
      this.isLastItem = false});

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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: [
                Icon(iconData),
                SizedBox(width: 10.0),
                Text(title,
                    style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.tertiary)),
              ],
            ),
            Icon(Icons.navigate_next),
          ],
        ),
      ),
    );
  }
}
