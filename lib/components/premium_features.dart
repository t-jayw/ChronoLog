// premium_features.dart

import 'package:flutter/material.dart';

class PremiumFeatures extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Premium Features:",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12), // To provide some spacing
          Text("• Add unlimited watches to your collection"),
          Text("• Take unlimited measurements"),
          Text("• Support continued development"),
          Text("• First look at all new features"),
        ],
      ),
    );
  }
}
