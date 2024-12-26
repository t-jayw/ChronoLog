import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../generic_alert.dart';
import '../premium/premium_needed_dialog.dart';
import '../../database_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:share_plus/share_plus.dart';

import '../../providers/timepiece_list_provider.dart';
import '../primary_button.dart';

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

void _showPremiumNeededDialog(BuildContext context, String primaryText) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return PremiumNeededDialog(
        primaryText: primaryText,
      );
    },
  );
}

class ManageDataModal extends ConsumerWidget {
  ManageDataModal({Key? key}) : super(key: key);

  final String versionNumber = "1.3.0";
  // replace with actual value

  final DatabaseHelper _db = DatabaseHelper();

  Future<bool> _isPremiumActivated() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getBool('is_premium_active') == true;
  }

  Future<String> _saveFile(String fileName, String content) async {
    final directory =
        await getTemporaryDirectory(); // You'll need the 'path_provider' package for this
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(content);
    return file.path;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timepieceProvider = ref.read(timepieceListProvider.notifier);

    return FutureBuilder<bool>(
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
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context)
                        .dialogBackgroundColor, // Set the background color here
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      //TimeDisplay(),
                      SizedBox(height: 20),

                      Text(
                        'Manage Data',
                        style: TextStyle(
                            fontSize: 30,
                            color: Theme.of(context).colorScheme.tertiary),
                      ),
                      SizedBox(height: 20),

                      // Expanded(child: PurchaseOptions()),
                      Stack(
                        children: [
                          ListGroup(
                            items: [
                              // Add more items as needed
                              ManageDataItem(
                                title: 'Export Data to CSV',
                                bodyText:
                                    'Export CSV formatted data of all measurements', // Example usage
                                iconData: Icons.email,
                                onTap: () async {
                                  String csvData = await _db.exportDataToCsv();

                                  print(csvData);
                                  String fileName = "exported_data.csv";

                                  final path = await _saveFile(fileName,
                                      csvData); // We need to save CSV data to a temporary file first
                                  final xfile = XFile(path);
                                  final result = await Share.shareXFiles(
                                    [xfile],
                                  );

                                  if (result.status ==
                                      ShareResultStatus.success) {
                                    print('CSV shared successfully!');
                                  } else if (result.status ==
                                      ShareResultStatus.dismissed) {
                                    print('User dismissed the share sheet.');
                                  }
                                },
                              ),
                              ManageDataItem(
                                title: 'Backup Data',
                                bodyText:
                                    'Backup the state of your database to a file and restore on a new device.',
                                iconData: Icons.download,
                                onTap: () async {
                                  print('calling backup db');
                                  await _db.backupDatabase();
                                },
                              ),
                              ManageDataItem(
                                title: 'Restore (Caution!)',
                                bodyText:
                                    'Choose a previously saved file to restore from. ⚠️Overwrites everything⚠️',
                                iconData: Icons.upload,
                                onTap: () async {
                                  print('restoring backup db');
                                  bool success = await _db.restoreDatabase();

                                  if (success) {
                                    timepieceProvider.initTimepieces();
                                    showGenericAlert(
                                        context: context,
                                        title: 'Restore Successful',
                                        contentLines: [
                                          'Your database has been backed up successfully.',
                                        ]);
                                  } else {
                                    showGenericAlert(
                                      context: context,
                                      title: 'Restore Unsuccessful',
                                      contentLines: [
                                        'The app was unable to restore the database from your selected file.'
                                      ],
                                    );
                                  }
                                },
                                isLastItem: true,
                              ),
                            ],
                          ),
                          if (!isPremium)
                            Positioned.fill(
                              child: Material(
                                color: Colors.grey.withOpacity(
                                    0.7), // semi-transparent overlay
                                child: InkWell(
                                  onTap: () {
                                    _showPremiumNeededDialog(
                                        context, 'Premium Required');
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

                      PrimaryButton(
                        child: Text(
                          "Close",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ListGroup extends StatelessWidget {
  final List<ManageDataItem> items;

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
