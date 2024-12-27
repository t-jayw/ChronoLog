import 'dart:async';

import 'package:chronolog/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:chronolog/screens/purchase_screen.dart';

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

  final String versionNumber = "1.6.0";
  // replace with actual value

  final DatabaseHelper _db = DatabaseHelper();

  void _navigateToClockScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ClockScreen(), // Ensure ClockScreen is defined and imported
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Version: $versionNumber',
              style: TextStyle(fontSize: 12),
            ),
            Text(
              ' • ', // Bullet separator
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
                return SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              },
            ),
          ],
        ),
        FutureBuilder<SharedPreferences>(
          future: SharedPreferences.getInstance(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return SizedBox.shrink();

            final prefs = snapshot.data!;
            final isPremium = prefs.getBool('premiumActive') ?? false;

            if (!isPremium) return SizedBox.shrink();

            return Text(
              'Premium',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            );
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
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.tertiary,
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(2.0), // Increased padding
                      child: Icon(
                        Icons.access_time,
                        size: 40, // Increased size
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    onPressed: () => _navigateToClockScreen(context),
                    tooltip: 'Open Clock',
                    iconSize: 68, // Increased overall button size
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
              title: 'Email Me',
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
              isLastItem: false,
            ),

            ListItem(
              title: 'Purchase Options',
              iconData: Icons.shopping_cart,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PurchaseScreen()),
                );
              },
            ),

            // Add more items as needed
          ],
        ),
        SizedBox(height: 4),

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
                      fontSize: 11,
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
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    ' in Boulder, CO',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '© 2024 Tyler Wood',
              style: TextStyle(
                fontSize: 8,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            FooterBannerAdWidget(bottomPadding: 20.0),
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
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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

  ListItem({
    required this.title,
    required this.iconData,
    required this.onTap,
    this.isLastItem = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
          decoration: BoxDecoration(
            border: isLastItem
                ? null
                : Border(
                    bottom: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                      width: 0.5,
                    ),
                  ),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                iconData,
                color: Theme.of(context).colorScheme.tertiary,
                size: 16,
              ),
              SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.outline,
                size: 16,
              ),
            ],
          ),
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

Future<String> getPurchaseDebugInfo() async {
  // Implement this function to fetch purchase-related debug information
  // For example, you can use a hypothetical function to fetch this information
  return 'Purchase debug information';
}

void showDebugInfoModal(BuildContext context) async {
  final prefsData = await getSharedPreferencesData();
  final purchaseInfo = await getPurchaseDebugInfo();
  final allDebugInfo = 'SHARED PREFERENCES:\n$prefsData\n\nPURCHASE INFO:\n$purchaseInfo';

  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Debug Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: allDebugInfo));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Debug info copied to clipboard')),
                          );
                        },
                        tooltip: 'Copy to clipboard',
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_forever),
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.clear();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('All preferences cleared')),
                          );
                        },
                        tooltip: 'Clear all preferences',
                      ),
                    ],
                  ),
                ],
              ),
              Divider(color: Theme.of(context).colorScheme.inverseSurface),
              Text(
                'Shared Preferences:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              Text(
                prefsData,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Purchase Information:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              Text(
                purchaseInfo,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
