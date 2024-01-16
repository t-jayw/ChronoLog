import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../components/premium/premium_features.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../components/premium/premium_package_tile.dart';

Future<void> _setPremiumActive(bool value) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool('premiumActive', value);
  Posthog().capture(
    eventName: 'set_premium_active',
    properties: {},
  );
}

class PurchaseScreen extends StatefulWidget {
  @override
  _PurchaseScreenState createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  List<Package> _packages = [];
  bool _loadingPackages = true;
  bool _hasPurchased = false;
  bool _isPremiumActive = false;
  bool _isEventFired = false; // Add this flag

  @override
  void initState() {
    super.initState();
    _fetchAvailablePackages();
    _checkPurchasedStatus();
    _checkPremiumStatus();

    if (!_isEventFired) {
      Posthog().screen(screenName: 'purchase_page');
      _isEventFired = true; // Set the flag to true after firing the event
    }
  }

  Future<void> _checkPurchasedStatus() async {
    print('checking purchase status');
    final prefs = await SharedPreferences.getInstance();
    try {
      final CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      bool isPremium = customerInfo.entitlements.active.containsKey('premium');
      // bool isPremium = true;

      if (isPremium) {
        print('customerInfo.entitlements.active contains premium');
        print(customerInfo.entitlements.active);
      }

      // Update the local state (if you still need this)
      setState(() {
        _isPremiumActive = isPremium;
      });

      // Save the premium status to shared preferences
      await prefs.setBool('isPremiumActive', isPremium);
    } catch (e) {
      print("Error fetching purchaser info: $e");
    }
  }

  Future<void> _checkPremiumStatus() async {
    print('checking prem status');
    final prefs = await SharedPreferences.getInstance();
    bool isPremium = prefs.getBool('isPremiumActive') ?? false;
    print('---------');
    setState(() {
      _isPremiumActive = isPremium;
    });
    print(_isPremiumActive);
  }

  Future<void> _fetchAvailablePackages() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        setState(() {
          _packages = offerings.current!.availablePackages;
          _loadingPackages = false;
        });
      }
    } catch (e) {
      print("Error while fetching offerings: $e");
      setState(() {
        _loadingPackages = false;
      });
    }
  }

  Future<void> _restorePurchases() async {
    print('_restorePurchases');
    CustomerInfo restoredInfo = await Purchases.restorePurchases();
    print(restoredInfo.toJson());

    try {
      CustomerInfo restoredInfo = await Purchases.restorePurchases();
      print(restoredInfo.toString());
      // check restored customerInfo to see if entitlement is now active
      if (restoredInfo.entitlements.active.containsKey('premium')) {
        await _setPremiumActive(true);
        setState(() {
          _hasPurchased = true; // Assuming you want to set this too
        });
        _showSuccessDialog('Purchases have been restored');
      }
    } on PlatformException catch (e) {
      print("Error restoring purchases: $e");
      _showErrorDialog(
          e.message ?? 'An error occurred while restoring purchases.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          ElevatedButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Success'),
        content: Text(message),
        actions: <Widget>[
          ElevatedButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> _purchasePackage(Package package) async {
    print('_purchasePackage()');
    try {
      final purchaseResult = await Purchases.purchasePackage(package);
      _checkPurchasedStatus();
      if (purchaseResult.entitlements.active.isNotEmpty) {
        await _setPremiumActive(true);
        _showSuccessDialog("Purchase was successful");
      }
    } catch (e) {
      if (e is PlatformException) {
        if (e.code == '1' && e.details['userCancelled'] == true) {
          print("Purchase was cancelled by the user.");
          // You can show a user-friendly message here or choose to do nothing
          _showErrorDialog(
              "Purchase was cancelled. Please try again if this was unintended.");
        } else {
          print("Purchase error: $e");
          // Handle other types of PlatformException here
          _showErrorDialog(
              "An error occurred during the purchase. Please try again later.");
        }
      } else {
        print("Unexpected error: $e");
        _showErrorDialog(
            "An unexpected error occurred. Please try again later.");
      }
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Premium')),
      body: _loadingPackages ? _buildLoadingIndicator() : _buildPackageList(),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(child: CircularProgressIndicator());
  }

  Widget _buildPackageList() {
    return ListView(
      children: [
        ...List.generate(_packages.length, (index) {
          final package = _packages[index];
          return Column(
            children: [
              PremiumFeatures(),
              if (_isPremiumActive)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Thank you for your purchase!',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              else
                PremiumPackageTile(
                  package: package,
                  onPurchase: _purchasePackage,
                )
            ],
          );
        }),
        // Adding restore purchases hyperlink here
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: InkWell(
              onTap: _restorePurchases,
              child: Text(
                'Restore Purchases',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Colors.blue,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),

        // if (kDebugMode)
        //   Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       FutureBuilder<CustomerInfo>(
        //         future: Purchases.getCustomerInfo(),
        //         builder: (context, snapshot) {
        //           if (snapshot.connectionState == ConnectionState.done &&
        //               snapshot.hasData) {
        //             //print(snapshot.toString());

        //             return Column(
        //               children: [
        //                 Text(
        //                     'App User ID: ${snapshot.data!.originalAppUserId}'),
        //                 Text(
        //                     'Entitlements: ${snapshot.data!.entitlements.all.keys.join(', ')}'),
        //                 // ... other data from CustomerInfo as desired
        //               ],
        //             );
        //           } else if (snapshot.hasError) {
        //             return Text(
        //                 'Error fetching customer info: ${snapshot.error}');
        //           }
        //           return CircularProgressIndicator();
        //         },
        //       ),
        //       FutureBuilder<Offerings>(
        //         future: Purchases.getOfferings(),
        //         builder: (context, snapshot) {
        //           if (snapshot.connectionState == ConnectionState.done &&
        //               snapshot.hasData) {
        //             final currentOffering = snapshot.data!.current;
        //             if (currentOffering != null) {
        //               final packages = currentOffering.availablePackages;
        //               return Column(
        //                 children: [
        //                   Text(
        //                       'Current Offering: ${currentOffering.identifier}'),
        //                   ...packages.map((package) {
        //                     // Print package details
        //                     print("Package Identifier: ${package.identifier}");
        //                     print(
        //                         "Product Title: ${package.storeProduct.title}");
        //                     print(
        //                         "Product Price: ${package.storeProduct.priceString}");

        //                     // Return package details for UI
        //                     return ListTile(
        //                       title: Text(package.storeProduct.title),
        //                       subtitle: Text(package.storeProduct.description),
        //                       trailing: Text(package.storeProduct.priceString),
        //                     );
        //                   }).toList(),
        //                   // ... other data from Offerings as desired
        //                 ],
        //               );
        //             } else {
        //               return Text('No current offering available.');
        //             }
        //           } else if (snapshot.hasError) {
        //             return Text('Error fetching offerings: ${snapshot.error}');
        //           }
        //           return CircularProgressIndicator();
        //         },
        //       ),

        //       SizedBox(height: 20), // Add some spacing
        //     ],
        //   ),
      ],
    );
  }
}
