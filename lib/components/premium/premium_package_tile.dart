import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/models/package_wrapper.dart';

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
    if (package.offeringIdentifier == "Luxury Access") {
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
      margin: EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: packageType == "luxury"
                  ? Theme.of(context).colorScheme.tertiary.withOpacity(0.1)
                  : Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              packageType == "luxury" 
                  ? CupertinoIcons.star_fill
                  : CupertinoIcons.checkmark_circle_fill,
              color: packageType == "luxury"
                  ? Theme.of(context).colorScheme.tertiary
                  : Theme.of(context).colorScheme.primary,
              size: 16,
            ),
          ),
          SizedBox(width: 12.0),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
                height: 1.3,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Package Type: $packageType');

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: packageType == "luxury"
                  ? Color(0xFFE5E4E2).withOpacity(0.8)
                  : Color(0xFFCD7F32).withOpacity(0.5),
              width: packageType == "luxury" ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (packageType == "luxury"
                    ? Color(0xFFE5E4E2)
                    : Color(0xFFCD7F32))
                    .withOpacity(0.15),
                blurRadius: 16,
                offset: Offset(0, 4),
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
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
                              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            package.storeProduct.title,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.tertiary,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            package.storeProduct.description,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                              fontSize: 15,
                              height: 1.4,
                              letterSpacing: 0.2,
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
                                  ? Theme.of(context).colorScheme.tertiary
                                  : Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            color: packageType == "luxury"
                                ? Theme.of(context).colorScheme.tertiary
                                : Theme.of(context).colorScheme.tertiary,
                            child: Text(
                              "Buy Now",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
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
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.1),
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
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 16),
                    Column(
                      children: _getFeatures()
                          .map((feature) => _buildFeatureItem(context, feature))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
