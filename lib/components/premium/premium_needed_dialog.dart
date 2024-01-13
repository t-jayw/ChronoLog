import 'package:flutter/material.dart';
import '../../screens/purchase_screen.dart';
import '../custom_tool_tip.dart';
import '../primary_button.dart';

class PremiumNeededDialogAddTimingRun extends StatelessWidget {
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
        mainAxisSize:
            MainAxisSize.min, // Adjusts the column size to its content
        children: [
          Text(
            "Free version limited to one timing run!",
            textAlign: TextAlign.center,
          ),
          Divider(), // Divider

          Text(
            "Upgrade to premium to unlock unlimited usage and all features.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10),
          ),
          SizedBox(height: 12), // Add some spacing
          Divider(), // Divider
          PrimaryButton(
            child: Text(
              "View Premium",
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
          SecondaryButton(
            text: "Dismiss",
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
          Divider(), // Divider
          CustomToolTip(
            mainAxisAlignment: MainAxisAlignment.center,
            child: Flexible(
              child: Text(
                "You can delete measurements in the existing Timing Run",
                style:
                    TextStyle(fontSize: 12.0), // you can style your text here
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PremiumNeededDialogAddWatch extends StatelessWidget {
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
        mainAxisSize:
            MainAxisSize.min, // Adjusts the column size to its content
        children: [
          Text(
            "Free version limited to one timepiece!",
            textAlign: TextAlign.center,
          ),
          Divider(), // Divider
          Text(
            "Upgrade to premium to unlock unlimited usage and all features.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10),
          ),
          SizedBox(height: 12), // Add some spacing
          Divider(), // Divider
          PrimaryButton(
            child: Text(
              "View Premium",
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
          SecondaryButton(
            text: "Dismiss",
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      ),
    );
  }
}
