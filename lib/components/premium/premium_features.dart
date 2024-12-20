import 'package:flutter/cupertino.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          "Features",
          style: TextStyle(
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
            fontSize: 12,
            decoration: TextDecoration.none,
          ),
        ),
        SizedBox(height: 6),
        ..._getFeatures()
            .map((feature) => PremiumFeatureItem(feature: feature))
            .toList(),
      ],
    );
  }
}

class PremiumFeatureItem extends StatelessWidget {
  final String feature;

  PremiumFeatureItem({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 6),
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.star_fill, 
            color: CupertinoTheme.of(context).primaryColor,
            size: 14
          ),
          SizedBox(width: 8.0),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(
                fontSize: 13,
                color: CupertinoColors.label.resolveFrom(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
