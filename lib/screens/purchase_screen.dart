import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/premium/premium_product_display.dart';

class PurchaseScreen extends StatefulWidget {
  @override
  _PurchaseScreenState createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  List<Package> _packages = [];
  bool _loadingPackages = true;
  Map<String, bool> _entitlementStatus = {};
  bool _isEventFired = false;

  final List<String> _entitlements = ['in_app_premium', 'in_app_luxury'];

  static const String ENTITLEMENTS_KEY = 'activeEntitlements';

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
    try {
      final CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      final prefs = await SharedPreferences.getInstance();
      
      Map<String, bool> newStatus = {};
      List<String> activeEntitlements = [];

      // Check each entitlement
      for (String entitlement in _entitlements) {
        bool isActive = customerInfo.entitlements.active.containsKey(entitlement);
        newStatus[entitlement] = isActive;
        
        if (isActive) {
          activeEntitlements.add(entitlement);
          // Store purchase date if not already stored
          String dateKey = '${entitlement}_purchaseDate';
          if (!prefs.containsKey(dateKey)) {
            await prefs.setString(dateKey, DateTime.now().toIso8601String());
          }
        }
      }

      // Update state and storage
      setState(() => _entitlementStatus = newStatus);
      await prefs.setStringList(ENTITLEMENTS_KEY, activeEntitlements);
      
      // Track purchase status
      Posthog().capture(
        eventName: 'entitlement_status_check',
        properties: {
          'active_entitlements': activeEntitlements,
          'has_active_entitlements': activeEntitlements.isNotEmpty,
        },
      );
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
    try {
      final purchaseResult = await Purchases.purchasePackage(package);
      
      if (purchaseResult.entitlements.active.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final purchaseDate = DateTime.now().toIso8601String();

        // Update entitlements and store purchase date
        for (String entitlement in purchaseResult.entitlements.active.keys) {
          await _setEntitlementActive(entitlement, true);
          await prefs.setString('${entitlement}_purchaseDate', purchaseDate);
        }

        // Track successful purchase
        Posthog().capture(
          eventName: 'successful_purchase',
          properties: {
            'product_id': package.storeProduct.identifier,
            'price': package.storeProduct.price,
            'currency': package.storeProduct.currencyCode,
          },
        );

        _showSuccessDialog("Thank you for your purchase!");
        await _checkEntitlementStatus(); // Refresh status
      }
    } catch (e) {
      _handlePurchaseError(e);
    }
  }

  void _handlePurchaseError(dynamic error) {
    String errorMessage = "An unexpected error occurred. Please try again later.";
    
    if (error is PlatformException) {
      if (error.code == '1' && error.details['userCancelled'] == true) {
        return; // Don't show error for user cancellation
      }
      errorMessage = error.message ?? errorMessage;
    }

    // Track purchase error
    Posthog().capture(
      eventName: 'purchase_error',
      properties: {
        'error_message': errorMessage,
        'error_type': error.runtimeType.toString(),
      },
    );

    _showErrorDialog(errorMessage);
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

  Future<void> _removeAllActiveKeys() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    for (String key in keys) {
      if (key.endsWith('Active')) {
        await prefs.remove(key);
      }
    }
    print('All *Active keys have been removed from local storage.');
  }

  Future<void> _simulateLuxuryPurchase() async {
    await _setEntitlementActive('in_app_luxury', true);
    setState(() {
      _entitlementStatus['in_app_luxury'] = true;
    });
    _showSuccessDialog("Simulated purchase: Luxury entitlement is now active.");
  }

  Future<void> _simulatePremiumPurchase() async {
    await _setEntitlementActive('in_app_premium', true);
    setState(() {
      _entitlementStatus['in_app_premium'] = true;
    });
    _showSuccessDialog("Simulated purchase: Premium entitlement is now active.");
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
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            spacing: 8.0, // Space between buttons
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _removeAllActiveKeys,
                child: Text('Remove All Active Keys'),
              ),
              ElevatedButton(
                onPressed: _simulateLuxuryPurchase,
                child: Text('Simulate Luxury Purchase'),
              ),
              ElevatedButton(
                onPressed: _simulatePremiumPurchase,
                child: Text('Simulate Premium Purchase'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
