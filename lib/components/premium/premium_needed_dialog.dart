import 'package:flutter/material.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import '../../screens/purchase_screen.dart';
import 'package:flutter/cupertino.dart';

void showPremiumNeededDialog(BuildContext context, String text, String reason) {
  // Add Posthog tracking
  Posthog().capture(
    eventName: 'paywall',
    properties: {
      'reason': reason,
      'text': text,
    },
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return PremiumNeededDialog(
        primaryText: text,
      );
    },
  );
}

class PremiumNeededDialog extends StatelessWidget {
  final String primaryText;
  final String reason;

  const PremiumNeededDialog({
    Key? key,
    required this.primaryText,
    this.reason = 'default_paywall',
  }) : super(key: key);

  List<Widget> buildFeatureList() {
    return [
      buildFeatureItem("Unlimited Access", "No more restrictions"),
      buildFeatureItem("Premium Features", "Access all premium features"),
      buildFeatureItem("Ad-Free Experience", "Enjoy without interruptions"),
    ];
  }

  Widget buildFeatureItem(String title, String subtitle) {
    return Builder(
      builder: (BuildContext context) => Container(
        margin: EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                CupertinoIcons.star_fill,
                color: Theme.of(context).colorScheme.secondary,
                size: 14,
              ),
            ),
            SizedBox(width: 8.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
                      height: 1.2,
                      letterSpacing: 0.1,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                      height: 1.2,
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

  Widget _buildSocialProof(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(CupertinoIcons.person_2_fill, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "Used by 100+ watch collectors",
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
              ),
              softWrap: true,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Color(0xFFCD7F32).withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFCD7F32).withOpacity(0.15),
              blurRadius: 8,
              offset: Offset(0, 2),
              spreadRadius: 1,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App name
                Text(
                  "ChronoLog",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 8),
                
                // Title
                Text(
                  "Upgrade to Premium",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 10),
                
                // Primary message
                Text(
                  primaryText,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                    fontSize: 15,
                    height: 1.4,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 16),
                
                // Social proof
                _buildSocialProof(context),
                SizedBox(height: 16),
                
                // Feature list title
                Text(
                  "Included Features",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12),
                
                // Feature list
                ...buildFeatureList(),
                SizedBox(height: 24),

                // Upgrade button
                CupertinoButton(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Theme.of(context).colorScheme.tertiary,
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Text(
                      "Upgrade Now",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => PurchaseScreen()),
                    );
                  },
                ),
                SizedBox(height: 12),
                
                // Dismiss button
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    "Not Now",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
