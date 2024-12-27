import 'dart:io';

import 'package:flutter/cupertino.dart';
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

  final DatabaseHelper _db = DatabaseHelper();

  Future<bool> _isPremiumActivated() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('premiumActive') == true;
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
    return FutureBuilder<bool>(
      future: _isPremiumActivated(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        bool isPremium = snapshot.data ?? false;

        return Container(
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground.resolveFrom(context),
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Drag indicator
                Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: CupertinoColors.separator.resolveFrom(context),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                  margin: EdgeInsets.only(bottom: 16),
                ),
                
                Text(
                  'Manage Data',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label.resolveFrom(context),
                  ),
                ),
                
                Divider(
                  color: CupertinoColors.separator.resolveFrom(context),
                  height: 32,
                ),

                Stack(
                  children: [
                    Column(
                      children: [
                        _buildDataItem(
                          context,
                          title: 'Export Data to CSV',
                          subtitle: 'Export CSV formatted data of all measurements',
                          icon: CupertinoIcons.arrow_down_doc,
                          onTap: () async {
                            String csvData = await _db.exportDataToCsv();
                            String fileName = "exported_data.csv";
                            final path = await _saveFile(fileName, csvData);
                            final xfile = XFile(path);
                            await Share.shareXFiles([xfile]);
                          },
                        ),
                        _buildDataItem(
                          context,
                          title: 'Backup Data',
                          subtitle: 'Backup database state to restore on a new device',
                          icon: CupertinoIcons.cloud_download,
                          onTap: () async {
                            await _db.backupDatabase();
                          },
                        ),
                        _buildDataItem(
                          context,
                          title: 'Restore (Caution!)',
                          subtitle: '⚠️ Choose backup file to restore. Overwrites everything',
                          icon: CupertinoIcons.cloud_upload,
                          onTap: () async {
                            bool success = await _db.restoreDatabase();
                            if (success) {
                              ref.read(timepieceListProvider.notifier).initTimepieces();
                              showGenericAlert(
                                context: context,
                                title: 'Restore Successful',
                                contentLines: ['Your database has been restored successfully.'],
                              );
                            } else {
                              showGenericAlert(
                                context: context,
                                title: 'Restore Failed',
                                contentLines: ['Unable to restore from selected file.'],
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    if (!isPremium)
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: () => _showPremiumNeededDialog(context, 'Premium Required'),
                          child: Container(
                            color: CupertinoColors.systemBackground.withOpacity(0.7),
                          ),
                        ),
                      ),
                  ],
                ),

                SizedBox(height: 20),
                
                CupertinoButton(
                  child: Text(
                    'Close',
                    style: TextStyle(
                      color: CupertinoColors.label.resolveFrom(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDataItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.symmetric(vertical: 8),
      onPressed: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onPrimary,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary.withOpacity(0.8),
                      fontSize: 12,
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
