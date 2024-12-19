import 'package:flutter/material.dart';

class PremiumFeatures extends StatelessWidget {
  final String productTitle; // "premium" or "luxury"

  const PremiumFeatures({
    Key? key,
    required this.productTitle,
  }) : super(key: key);

  List<String> _getFeatures() {
    print("productTitle: $productTitle.");
    if (productTitle == "Limited Edition") {
      return [
        "All of Premium features, plus:",
        "More support for a good app."
      ];
    } else {
      return [
        "Lifetime access.",
        "Unlimited usage.",
        "New features.",
        "Prioritized feedback.",
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    Color tertiaryColor = Theme.of(context).colorScheme.tertiary;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Text(
              "Features",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: tertiaryColor,
              ),
            ),
          ),
          Divider(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2), thickness: 0.5),
          SizedBox(height: 8),
          ..._getFeatures()
              .map((feature) => PremiumFeatureItem(feature: feature))
              .toList(),
        ],
      ),
    );
  }
}

class PremiumFeatureItem extends StatelessWidget {
  final String feature;

  PremiumFeatureItem({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.0),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.inverseSurface.withOpacity(0.1),
            width: 0.25,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.star, color: Theme.of(context).colorScheme.secondary, size: 16),
          SizedBox(width: 8.0),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
