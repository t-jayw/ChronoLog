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
    if (package.storeProduct.identifier == "in_app_luxury") {
      return [
        "All Premium features",
        "Bespoke, small batch application code, with a focus on quality and performance",
        "Unit test coverage",
        "iOS Only"
      ];
    } else {
      return [
        "One time payment.",
        "Lifetime access.",
        "Unlimited watches and measurements.",
        "Advanced analytics and insights",
        "Backup and Export functionality",
        "Premium support"
      ];
    }
  }

  Widget _buildFeatureItem(BuildContext context, String feature) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              CupertinoIcons.star_fill,
              color: Theme.of(context).colorScheme.secondary,
              size: 14,
            ),
          ),
          SizedBox(width: 8.0),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
                height: 1.2,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialProof(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(CupertinoIcons.person_2_fill, size: 16),
          SizedBox(width: 8),
          Text(
            "Used by 100+ watch collectors",
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeLimitedBadge() {
    return Container(
      // padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      // decoration: BoxDecoration(
      //   color: Colors.red.withOpacity(0.1),
      //   borderRadius: BorderRadius.circular(16),
      // ),
      // child: Text(
      //   "Limited Time Offer",
      //   style: TextStyle(
      //     color: Colors.red,
      //     fontSize: 12,
      //     fontWeight: FontWeight.w600,
      //   ),
      // ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Remove debug prints in production code
    assert(() {
      print('=== Package Debug Info ===');
      print('Package Type: $packageType');
      print('Product ID: ${package.storeProduct.identifier}');
      print('Price: ${package.storeProduct.priceString}');
      return true;
    }());

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SingleChildScrollView(
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
                  blurRadius: 8,
                  offset: Offset(0, 2),
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(24),
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
                Flexible(
                  fit: FlexFit.loose,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSocialProof(context),
                        SizedBox(height: 8),
                        if (package.storeProduct.identifier == "in_app_luxury") ...[
                          _buildTimeLimitedBadge(),
                          SizedBox(height: 12),
                        ],
                        Text(
                          "Included Features",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 12),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: _getFeatures()
                              .map((feature) => _buildFeatureItem(context, feature))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
