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
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(8),
        ),
        if (isEntitlementActive)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'You have active $entitlement access!',
              style: TextStyle(fontSize: 18),
            ),
          )
        else
          CarouselSlider(
            options: CarouselOptions(
              height: screenHeight * 0.4, // 66% of screen height
              viewportFraction:
                  0.8, // Adjusted to 80% of screen width to show next card
              enlargeCenterPage: true,
              enableInfiniteScroll: true,
              autoPlay: false,
            ),
            items: entitlementPackages
                .map(
                  (package) => Builder(
                    builder: (BuildContext context) {
                      print('Package ID: ${package.identifier}');
                      print('Package Type: ${package.packageType}');
                      print('Product Title: ${package.storeProduct.title}');
                      print(
                          'Product Description: ${package.storeProduct.description}');
                      print(
                          'Product Price: ${package.storeProduct.priceString}');

                      return PremiumPackageTile(
                        package: package,
                        packageType: package.packageType.toString(),
                        onPurchase: onPurchase,
                      );
                    },
                  ),
                )
                .toList(),
          ),
        SizedBox(height: 16),
      ],
    );
  }
}
