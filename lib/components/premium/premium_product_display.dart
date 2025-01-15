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
    if (packages.isEmpty) return SizedBox.shrink();

    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isEntitlementActive)
          Container(
            margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.tertiary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Premium Active',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.tertiary,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 12),
                _buildFeatureRow(
                  context,
                  Icons.check_circle,
                  'Thank you for your support!',
                ),
                SizedBox(height: 12),
                _buildFeatureRow(
                  context,
                  Icons.check_circle,
                  'All premium features are now unlocked',
                ),
                SizedBox(height: 12),
                _buildFeatureRow(
                  context,
                  Icons.check_circle,
                  'Enjoy unlimited timing runs and measurements',
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
              enableInfiniteScroll: packages.length > 1,
              autoPlay: false,
            ),
            items: packages
                .map((package) => PremiumPackageTile(
                      package: package,
                      packageType: package.packageType.toString(),
                      onPurchase: onPurchase,
                      isPremium: isEntitlementActive,
                    ))
                .toList(),
          ),
        SizedBox(height: 24),
      ],
    );
  }

  Widget _buildFeatureRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.secondary,
            size: 16,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
