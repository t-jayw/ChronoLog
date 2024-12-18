import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/premium/premium_product_display.dart';

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
  Map<String, bool> _entitlementStatus = {};
  bool _isEventFired = false;

  final List<String> _entitlements = ['in_app_premium'];

  @override
  void initState() {
    super.initState();
    _fetchAvailablePackages();
    _checkEntitlementStatus();

    if (!_isEventFired) {
      Posthog().screen(screenName: 'purchase_page');
      _isEventFired = true;
    }
  }

  Future<void> _checkEntitlementStatus() async {
    print('checking entitlement status');
    try {
      final CustomerInfo customerInfo = await Purchases.getCustomerInfo();

      setState(() {
        for (String entitlement in _entitlements) {
          _entitlementStatus[entitlement] =
              customerInfo.entitlements.active.containsKey(entitlement);
        }
      });

      final prefs = await SharedPreferences.getInstance();
      for (String entitlement in _entitlements) {
        await prefs.setBool(
            '${entitlement}Active', _entitlementStatus[entitlement] ?? false);
      }
    } catch (e) {
      print("Error fetching purchaser info: $e");
    }
  }

  Future<void> _fetchAvailablePackages() async {
    try {
      final offerings = await Purchases.getOfferings();
      print("\n=== OFFERINGS DEBUG INFO ===");
      print("All offerings: ${offerings.all.keys}");
      print("Current offering: ${offerings.current?.identifier}");

      if (offerings.current != null) {
        print("\nAvailable Packages in Current Offering:");
        offerings.current!.availablePackages.forEach((package) {
          print("\n- Package Details:");
          print("  • Package ID: ${package.identifier}");
          print("  • Product ID: ${package.storeProduct.identifier}");
          print("  • Price: ${package.storeProduct.priceString}");
          print("  • Description: ${package.storeProduct.description}");
        });
      } else {
        print("\nWARNING: No current offering available");
      }

      // Print all offerings for debugging
      offerings.all.forEach((key, offering) {
        print("\nOffering: $key");
        offering.availablePackages.forEach((package) {
          print("  • Product: ${package.storeProduct.identifier}");
        });
      });

      setState(() {
        _packages = offerings.current!.availablePackages;
        _loadingPackages = false;
      });
    } catch (e) {
      print("\nERROR fetching offerings: $e");
      print("Stack trace: ${StackTrace.current}");
      setState(() {
        _loadingPackages = false;
      });
    }
  }

  Future<void> _restorePurchases() async {
    print('_restorePurchases');
    try {
      CustomerInfo restoredInfo = await Purchases.restorePurchases();
      print(restoredInfo.toJson());

      bool anyEntitlementRestored = false;

      // Check each entitlement in the list
      for (String entitlement in _entitlements) {
        if (restoredInfo.entitlements.active.containsKey(entitlement)) {
          await _setEntitlementActive(entitlement, true);
          setState(() {
            _entitlementStatus[entitlement] = true;
          });
          anyEntitlementRestored = true;
        }
      }

      if (anyEntitlementRestored) {
        _showSuccessDialog('Purchases have been restored');
      } else {
        _showErrorDialog('No purchases found to restore');
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
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(
          'Error',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text('OK', style: TextStyle(color: CupertinoColors.activeBlue)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(
          'Success',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text('OK', style: TextStyle(color: CupertinoColors.activeBlue)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _purchasePackage(Package package) async {
    print('_purchasePackage()');
    try {
      final purchaseResult = await Purchases.purchasePackage(package);
      await _checkEntitlementStatus();

      if (purchaseResult.entitlements.active.isNotEmpty) {
        for (String entitlement in purchaseResult.entitlements.active.keys) {
          await _setEntitlementActive(entitlement, true);
        }
        _showSuccessDialog("Purchase was successful");
      }
    } catch (e) {
      if (e is PlatformException) {
        if (e.code == '1' && e.details['userCancelled'] == true) {
          print("Purchase was cancelled by the user.");
          _showErrorDialog(
              "Purchase was cancelled. Please try again if this was unintended.");
        } else {
          print("Purchase error: $e");
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

  Future<void> _setEntitlementActive(String entitlement, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${entitlement}Active', value);
    Posthog().capture(
      eventName: 'set_entitlement_active',
      properties: {
        'entitlement': entitlement,
        'value': value,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upgrade')),
      body: _loadingPackages ? _buildLoadingIndicator() : _buildPackageList(),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(child: CircularProgressIndicator());
  }

  Widget _buildPackageList() {
    return ListView(
      children: [
        ..._entitlements.map((entitlement) => PremiumProductDisplay(
              entitlement: entitlement,
              packages: _packages,
              isEntitlementActive: _entitlementStatus[entitlement] ?? false,
              onPurchase: _purchasePackage,
            )),
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
      ],
    );
  }
}
