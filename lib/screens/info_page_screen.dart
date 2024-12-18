import 'dart:async';

import 'package:chronolog/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../components/ads/footer_banner_ad.dart';
import '../components/time_display.dart';
import '../database_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:posthog_flutter/posthog_flutter.dart';

import '../components/user_settings/manage_settings_modal.dart';
import '../components/user_settings/manage_data_modal.dart';

import 'package:chronolog/screens/clock_screen.dart';


Future<void> logAllPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  print('--- SharedPreferences State ---');
  prefs.getKeys().forEach((key) {
    print('$key: ${prefs.get(key)}');
  });
  print('--------------------------------');
}

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

  final String versionNumber = "1.5.3";
  // replace with actual value

  final DatabaseHelper _db = DatabaseHelper();

  Future<bool> _isPremiumActivated() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isPremiumActive') ??
        false; // default to false if not found
  }

    void _navigateToClockScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClockScreen(), // Ensure ClockScreen is defined and imported
      ),
    );
  }

  void _showClockModal(BuildContext context) {
    // Implement the logic to show the clock modal here
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200, // Example height
          child: Center(
            child: Text('Clock Modal Content'), // Example content
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('info_page');
    Posthog().screen(
      screenName: 'info_page',
    );
    logAllPreferences();

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text(
          'ChronoLog',
          style: TextStyle(
              fontSize: 24, color: Theme.of(context).colorScheme.tertiary),
        ),
        Text(
          'Version: $versionNumber',
          style: TextStyle(fontSize: 12),
        ),
        FutureBuilder<String>(
          future: _db.getDatabaseVersion(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasData) {
              return Text('DB version: ${snapshot.data}',
                  style: TextStyle(fontSize: 12));
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}',
                  style: TextStyle(fontSize: 12));
            }
            // By default, show a loading spinner.
            return CircularProgressIndicator();
          },
        ),

        Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 0), // Placeholder to balance the Row
                Tooltip(
                  message: 'Open Clock Screen',
                  child: IconButton(
                    icon: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2), // Background color
                      ),
                      padding: EdgeInsets.all(8.0), // Padding around the icon
                      child: Icon(
                        Icons.access_time,
                        size: 30,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    onPressed: () => _navigateToClockScreen(context),
                    tooltip: 'Open Clock',
                  ),
                ),
              ],
            ),
            Center(
              child: TimeDisplay(),
            ),
          ],
        ),


        // Expanded(child: PurchaseOptions()),
        ListGroup(
          items: [
            ListItem(
              title: 'Show Information',
              iconData: Icons.info,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WelcomeScreen()),
                );
              },
            ),

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
              title: 'SubmitFeedback',
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
                showModalBottomSheet(
                  context: context,
                  isScrollControlled:
                      true, // Set to true to make the bottom sheet full-screen
                  builder: (BuildContext context) {
                    // You can return the ManageSettingsScreen or a widget that is more suited for a modal layout
                    return DraggableScrollableSheet(
                      expand: false,
                      builder: (_, controller) => SingleChildScrollView(
                        controller: controller,
                        child:
                            ManageDataModal(), // Ensure your ManageSettingsScreen is suitable for this context
                      ),
                    );
                  },
                );
              },
            ),

            ListItem(
              title: 'Manage Settings',
              iconData: Icons.settings,
              onTap: () async {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled:
                      true, // Set to true to make the bottom sheet full-screen
                  builder: (BuildContext context) {
                    // You can return the ManageSettingsScreen or a widget that is more suited for a modal layout
                    return DraggableScrollableSheet(
                      expand: false,
                      builder: (_, controller) => SingleChildScrollView(
                        controller: controller,
                        child:
                            ManageSettingsWidget(), // Ensure your ManageSettingsScreen is suitable for this context
                      ),
                    );
                  },
                );
              },
              isLastItem: true,
            ),
            // Add more items as needed
          ],
        ),
        SizedBox(height: 10),

        // Expanded(
        //     child: Column(
        //   children: [],
        // )),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Made with ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  GestureDetector(
                    onDoubleTap: () {
                      showDebugInfoModal(context);
                    },
                    child: Text(
                      '⛰️',
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    ' in Boulder, CO',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Text(
                '© 2024 Tyler Wood',
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            SizedBox(height: 8),
            FooterBannerAdWidget(),
          ],
        ),
      ],
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

Future<String> getSharedPreferencesData() async {
  final prefs = await SharedPreferences.getInstance();
  final keys = prefs.getKeys();
  final prefsMap = keys.map((key) => '$key: ${prefs.get(key)}').join('\n');
  return prefsMap;
}

void showDebugInfoModal(BuildContext context) async {
  final prefsData = await getSharedPreferencesData();
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Text(prefsData),
        ),
      );
    },
  );
}

