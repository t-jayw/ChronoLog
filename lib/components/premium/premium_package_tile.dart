import 'package:chronolog/components/primary_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/models/package_wrapper.dart';

class PremiumPackageTile extends StatelessWidget {
  final Package package;
  final Function(Package) onPurchase;

  PremiumPackageTile({required this.package, required this.onPurchase});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onPurchase(package),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.secondary),
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4.0), // spacing between tiles
        child: ListTile(
          title: Text(package.storeProduct.title),
          subtitle: Text(package.storeProduct.description),
          trailing: Column(
            children: [
              PrimaryButton(
                onPressed: () => onPurchase(package),
                child: Text(package.storeProduct.priceString, style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary)),
              ),
            ],
          ),
          // leading: Text(package.storeProduct.priceString), // removed based on your initial code
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Adjust padding if necessary
        ),
      ),
    );
  }
}
