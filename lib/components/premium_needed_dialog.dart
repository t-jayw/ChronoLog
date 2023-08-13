import 'package:flutter/material.dart';
import '../screens/purchase_screen.dart';


class PremiumNeededDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.all(16),
      title: Row(
        children: [
          Expanded(
            child: Text(
              "Premium Needed",
              style: TextStyle(
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min, // Adjusts the column size to its content
        children: [
          Text("Purchase Premium to unlock all the features like adding unlimted watches"),
          SizedBox(height: 16), // Add some spacing
          ElevatedButton(
            child: Text("Learn more about premium"),
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
