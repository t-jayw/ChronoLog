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

  @override
  Widget build(BuildContext context) {
    Color borderColor = packageType == "luxury"
        ? Theme.of(context).colorScheme.primary // Luxury border color
        : Theme.of(context).colorScheme.secondary; // Premium border color

    return GestureDetector(
      onTap: () => onPurchase(package),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: SingleChildScrollView( // Make the content scrollable
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "ChronoLog",
                          style: TextStyle(
                            fontSize: 16, // Smaller font size for ChronoLog
                            fontWeight: FontWeight.normal,
                            color: Theme.of(context).colorScheme.onSurface,
                            fontFamily: 'NewYork',
                          ),
                        ),
                        Text(
                          package.storeProduct.title,
                          style: TextStyle(
                            fontSize: 20, // Original font size for title
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                            fontFamily: 'NewYork',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      package.storeProduct.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      package.storeProduct.priceString,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.tertiaryContainer,
                      ),
                    ),
                    PrimaryButton(
                      onPressed: () => onPurchase(package),
                      child: Text(
                        "Buy Now",
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              PremiumFeatures(productTitle: package.storeProduct.title),
            ],
          ),
        ),
      ),
    );
  }
}
