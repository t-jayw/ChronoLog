import 'dart:async';

import 'package:chronolog/screens/welcome_screen.dart';
import 'package:flutter/foundation.dart';
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

import '../components/analog_clock_face.dart';

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

  final String versionNumber = "1.7.0";
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

  Widget _buildDisplayElement(
    BuildContext context, {
    required Widget upperElement,
    required String label,
    VoidCallback? onTap,
  }) {
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        upperElement,
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 1,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
          ),
        ),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('info_page');
    Posthog().screen(screenName: 'info_page');
    logAllPreferences();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        // Version info - tight at the top
        Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('v$versionNumber', style: TextStyle(fontSize: 11)),
              Text(' • ', style: TextStyle(fontSize: 11)),
              FutureBuilder<String>(
                future: _db.getDatabaseVersion(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text('DB ${snapshot.data}', style: TextStyle(fontSize: 11));
                  }
                  return SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(strokeWidth: 1.5),
                  );
                },
              ),
            ],
          ),
        ),

        // Premium badge
        FutureBuilder<SharedPreferences>(
          future: SharedPreferences.getInstance(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return SizedBox.shrink();
            final isPremium = snapshot.data!.getBool('premiumActive') ?? false;
            if (!isPremium) return SizedBox.shrink();

            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.tertiary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'Premium',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            );
          },
        ),

        // Time display and clock button section
        Padding(
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TimeDisplay(),
                ),
                GestureDetector(
                  onTap: () => _navigateToClockScreen(context),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.tertiary,
                        width: 1.0,
                      ),
                    ),
                    child: StreamBuilder(
                      stream: Stream.periodic(Duration(seconds: 1)),
                      builder: (context, snapshot) {
                        return AnalogClockFace(
                          time: DateTime.now(),
                          size: 24.0,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // List of options (existing ListGroup widget)
        ListGroup(items: [
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
        ]),

        // ... rest of the existing footer content ...
        SizedBox(height: 30),

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
                      fontSize: 10,
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
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    ' in Boulder, CO',
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '© 2024 Tyler Wood',
              style: TextStyle(
                fontSize: 9,
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
          padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
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
                    fontSize: 16,
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
  final prefs = await SharedPreferences.getInstance();
  final isDebugEnabled = prefs.getBool('internalDebugMode') ?? false;

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
                        icon: Icon(
                          isDebugEnabled ? Icons.bug_report : Icons.bug_report_outlined,
                          color: isDebugEnabled ? Colors.green : null,
                        ),
                        onPressed: () async {
                          await _toggleDebugMode();
                          Navigator.pop(context);
                          showDebugInfoModal(context); // Refresh the modal
                        },
                        tooltip: 'Toggle Debug Mode',
                      ),
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
          
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _toggleDebugMode() async {
  final prefs = await SharedPreferences.getInstance();
  final isDebugEnabled = prefs.getBool('internalDebugMode') ?? false;
  await prefs.setBool('internalDebugMode', !isDebugEnabled);
}

Future<bool> isDebugEnabled() async {
  if (!kDebugMode) return false; // Always false in release
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('internalDebugMode') ?? false;
}
