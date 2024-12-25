import 'package:flutter/material.dart';
import '../../screens/purchase_screen.dart';
import '../primary_button.dart';
import 'package:flutter/cupertino.dart';

void showPremiumNeededDialog(BuildContext context, text) {
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

  const PremiumNeededDialog({
    Key? key,
    required this.primaryText,
  }) : super(key: key);

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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
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
              const SizedBox(height: 8),
              
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
              const SizedBox(height: 10),
              
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
              const SizedBox(height: 24),
              
              // Feature list
              ...buildFeatureList(),
              const SizedBox(height: 24),

              // Upgrade button
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => PurchaseScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  "Upgrade Now",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 16),
              
              // Dismiss button
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  "Not Now",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> buildFeatureList() {
    return [
      buildFeatureItem("Unlimited Access", "No more restrictions"),
      buildFeatureItem("Premium Features", "Access all premium features"),
      buildFeatureItem("Ad-Free Experience", "Enjoy without interruptions"),
    ];
  }

  Widget buildFeatureItem(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
