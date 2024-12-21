import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../premium/premium_package_tile.dart';

class PremiumProductDisplay extends StatelessWidget {
  final String entitlement;
  final List<Package> packages;
  final bool isEntitlementActive;
  final Function(Package) onPurchase;

  const PremiumProductDisplay({
    Key? key,
    required this.entitlement,
    required this.packages,
    required this.isEntitlementActive,
    required this.onPurchase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final entitlementPackages = packages
        .where((package) => package.offeringIdentifier == entitlement)
        .toList();

    if (entitlementPackages.isEmpty) return SizedBox.shrink();

    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isEntitlementActive)
          Container(
            margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You have active $entitlement access!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          CarouselSlider(
            options: CarouselOptions(
              height: screenHeight * 0.68,
              viewportFraction: 0.85,
              enlargeCenterPage: true,
              enlargeFactor: 0.2,
              enableInfiniteScroll: entitlementPackages.length > 1,
              autoPlay: false,
            ),
            items: entitlementPackages
                .map((package) => PremiumPackageTile(
                      package: package,
                      packageType: package.packageType.toString(),
                      onPurchase: onPurchase,
                    ))
                .toList(),
          ),
        SizedBox(height: 24),
      ],
    );
  }
}
