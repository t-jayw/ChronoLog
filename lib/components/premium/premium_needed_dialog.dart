import 'package:flutter/material.dart';
import '../../screens/purchase_screen.dart';
import '../primary_button.dart';

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
    return AlertDialog(
      titlePadding: const EdgeInsets.all(16),
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
            primaryText,
            textAlign: TextAlign.center,
          ),
          const Divider(), // Divider
          const Text(
            "Upgrade to premium to unlock unlimited usage and all features.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10),
          ),
          const SizedBox(height: 12), // Add some spacing
          const Divider(), // Divider
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
          const Divider(), // Divider
        ],
      ),
    );
  }
}
