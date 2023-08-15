import 'package:flutter/material.dart';
import '../../screens/purchase_screen.dart';
import '../primary_button.dart';


class PremiumNeededDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.all(16),
      title: Center(
        child: Text(
          "Unlock with Premium",
          style: TextStyle(
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min, // Adjusts the column size to its content
        children: [
          Text(
            "Some features, like adding more watches and exporting data, are unavailable in the free version. Upgrade to premium to unlock all features",
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12), // Add some spacing
          Divider(), // Divider
          SecondaryButton(
            text: "Okay",
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
          Divider(), // Divider
          PrimaryButton(
            child: Text(
              "Learn More",
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => PurchaseScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
