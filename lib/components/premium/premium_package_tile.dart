import 'package:chronolog/components/primary_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/models/package_wrapper.dart';
import 'premium_features.dart';

class PremiumPackageTile extends StatelessWidget {
  final Package package;
  final Function(Package) onPurchase;
  final String packageType; // "premium" or "luxury"

  PremiumPackageTile({
    required this.package,
    required this.onPurchase,
    required this.packageType,
  });

  List<String> _getFeatures() {
    if (packageType == "luxury") {
      return [
        "All Premium features, plus:",
        "Exclusive Limited Edition status",
        "Priority support and feature requests",
        "Early access to new features",
        "Premium concierge service"
      ];
    } else {
      return [
        "Lifetime access to all features",
        "Unlimited watch tracking",
        "Advanced analytics and insights",
        "Cloud backup and sync",
        "Premium support"
      ];
    }
  }

  Widget _buildFeatureItem(BuildContext context, String feature) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            packageType == "luxury" 
                ? CupertinoIcons.sparkles
                : CupertinoIcons.checkmark_circle_fill,
            color: packageType == "luxury"
                ? CupertinoTheme.of(context).primaryColor
                : CupertinoColors.activeBlue,
            size: 16,
          ),
          SizedBox(width: 12.0),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: packageType == "luxury"
                ? CupertinoTheme.of(context).primaryColor.withOpacity(0.2)
                : CupertinoColors.activeBlue.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "ChronoLog",
                          style: TextStyle(
                            color: CupertinoColors.secondaryLabel.resolveFrom(context),
                            fontSize: 12,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          package.storeProduct.title,
                          style: TextStyle(
                            color: CupertinoColors.label.resolveFrom(context),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          package.storeProduct.description,
                          style: TextStyle(
                            color: CupertinoColors.secondaryLabel.resolveFrom(context),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          package.storeProduct.priceString,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: packageType == "luxury" 
                                ? CupertinoTheme.of(context).primaryColor
                                : CupertinoColors.activeBlue,
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          color: packageType == "luxury"
                              ? CupertinoTheme.of(context).primaryColor
                              : CupertinoColors.activeBlue,
                          child: Text(
                            "Buy Now",
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () => onPurchase(package),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(
                color: CupertinoColors.separator.resolveFrom(context),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Included Features",
                    style: TextStyle(
                      color: CupertinoColors.secondaryLabel.resolveFrom(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12),
                  ..._getFeatures()
                      .map((feature) => _buildFeatureItem(context, feature))
                      .toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
