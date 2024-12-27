import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/premium/premium_product_display.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

class PurchaseScreen extends StatefulWidget {
  @override
  _PurchaseScreenState createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  List<Package> _packages = [];
  bool _loadingPackages = true;
  Map<String, bool> _entitlementStatus = {};
  bool _isEventFired = false;
  bool _isDebugExpanded = false;

  final List<String> _entitlements = ['premium'];

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
      
      print('RevenueCat Active Entitlements: ${customerInfo.entitlements.active.keys}');
      
      // Check both RevenueCat and local storage
      Map<String, bool> status = {};
      
      // Check RevenueCat entitlements
      for (String entitlement in customerInfo.entitlements.active.keys) {
        print('Setting entitlement: ${entitlement}Active to true');
        await prefs.setBool('${entitlement}Active', true);
        status[entitlement] = true;
      }
      
      // Check local storage for simulated purchases
      if (prefs.getBool('premiumActive') == true || 
          prefs.getBool('in_app_premiumActive') == true) {
        status['premium'] = true;
        status['in_app_premium'] = true;
      }

      // Update state for UI
      setState(() {
        _entitlementStatus = status;
      });

      Posthog().capture(
        eventName: 'entitlement_status_check',
        properties: {
          'active_entitlements': status.keys.toList(),
        },
      );
    } catch (e) {
      print("Error fetching purchaser info: $e");
    }
  }

  Future<void> _fetchAvailablePackages() async {
    try {
      setState(() => _loadingPackages = true);
      final offerings = await Purchases.getOfferings();

      if (offerings.current == null ||
          offerings.current!.availablePackages.isEmpty) {
        print("\nWARNING: No valid offerings found");
        throw PlatformException(
          code: 'no_offerings',
          message: 'No offerings are currently available.',
        );
      }

      setState(() {
        _packages = offerings.current!.availablePackages;
        _loadingPackages = false;
      });
    } catch (e) {
      print("\nERROR fetching offerings: $e");
      setState(() {
        _loadingPackages = false;
      });
      _showErrorDialog('Unable to load products. Please try again later.');
    }
  }

  Future<void> _restorePurchases() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Restoring Purchases...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );

    try {
      CustomerInfo restoredInfo = await Purchases.restorePurchases();
      Navigator.of(context).pop(); // Dismiss loading

      bool anyEntitlementRestored = false;
      List<String> restoredEntitlements = [];

      for (String entitlement in _entitlements) {
        if (restoredInfo.entitlements.active.containsKey(entitlement)) {
          await _setEntitlementActive(entitlement, true);
          setState(() {
            _entitlementStatus[entitlement] = true;
          });
          anyEntitlementRestored = true;
          restoredEntitlements.add(entitlement);
        }
      }

      if (anyEntitlementRestored) {
        _showRestoreSuccessDialog(restoredEntitlements);
      } else {
        _showErrorDialog('No purchases found to restore');
      }
    } catch (e) {
      Navigator.of(context).pop(); // Dismiss loading
      _handlePurchaseError(e);
    }
  }

  void _showRestoreSuccessDialog(List<String> restoredEntitlements) {
    showDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.check_mark_circled_solid,
              color: Colors.green,
              size: 28,
            ),
            SizedBox(width: 8),
            Text('Restored Successfully'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 16),
            Text(
              'Your purchases have been restored:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            ...restoredEntitlements
                .map((e) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '• ${e.replaceAll('_', ' ').toUpperCase()}',
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.secondaryLabel,
                        ),
                      ),
                    ))
                .toList(),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: Text('OK'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
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
            child:
                Text('OK', style: TextStyle(color: CupertinoColors.activeBlue)),
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
            child:
                Text('OK', style: TextStyle(color: CupertinoColors.activeBlue)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  void showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _purchasePackage(Package package) async {
    try {
      showLoadingDialog('Processing Purchase...');
      
      final purchaseResult = await Purchases.purchasePackage(package);
      final bool isPremium = purchaseResult.entitlements.active.isNotEmpty;
      
      if (isPremium) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('premiumActive', true);
        await prefs.setString('premium_purchaseDate', DateTime.now().toIso8601String());

        setState(() => _entitlementStatus = {'premium': true});
        
        Posthog().capture(
          eventName: 'successful_purchase',
          properties: {
            'product_id': package.storeProduct.identifier,
            'price': package.storeProduct.price,
          },
        );

        Navigator.of(context).pop(); // Dismiss loading before showing success
        _showPurchaseSuccessDialog();
      } else {
        Navigator.of(context).pop(); // Dismiss loading if not premium
      }
    } catch (e) {
      Navigator.of(context).pop(); // Dismiss loading on error
      _handlePurchaseError(e);
    }
  }

  void _handlePurchaseError(dynamic error) {
    String errorMessage =
        "An unexpected error occurred. Please try again later.";

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

  Future<void> _debugPrintEntitlements() async {
    final CustomerInfo customerInfo = await Purchases.getCustomerInfo();
    final prefs = await SharedPreferences.getInstance();

    String entitlementsInfo = '''
📱 Device Status:
${_entitlements.map((e) => '• $e: ${_entitlementStatus[e] ?? false ? "✓" : "✗"}').join('\n')}

💾 Local Storage:
${prefs.getKeys().where((k) => k.contains('Active') || k.contains('purchase')).map((k) => '• $k: ${prefs.get(k)}').join('\n')}

������� RevenueCat Status:
• Customer ID: ${customerInfo.originalAppUserId}
• Latest Exp: ${customerInfo.latestExpirationDate?.toString() ?? 'None'}
• Active Entitlements: ${customerInfo.entitlements.active.keys.isEmpty ? 'None' : customerInfo.entitlements.active.keys.join(', ')}

📊 Purchase History:
${customerInfo.nonSubscriptionTransactions.map((t) => '• ${t.productIdentifier}: ${t.purchaseDate}').join('\n')}
''';
    _showDebugInfoDialog('Entitlements Debug', entitlementsInfo);
  }

  Future<void> _debugPrintOfferings() async {
    final offerings = await Purchases.getOfferings();
    final currentOffering = offerings.current;

    String offeringsInfo = '''
🏷️ Current Offering: ${currentOffering?.identifier ?? 'None'}

📦 Available Packages:
${_packages.map((p) => '''• ${p.identifier}
  - Product: ${p.storeProduct.identifier}
  - Price: ${p.storeProduct.priceString}
  - Period: ${p.packageType}
  - Description: ${p.storeProduct.description}''').join('\n\n')}

⚠️ Issues:
• Packages Loading: ${_loadingPackages ? "In Progress" : "Complete"}
• Package Count: ${_packages.length}
• Has Current Offering: ${currentOffering != null}
''';
    _showDebugInfoDialog('Offerings Debug', offeringsInfo);
  }

  void _showDebugInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: message));
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Debug info copied to clipboard')));
              },
              child: Icon(Icons.copy, size: 20),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: SelectableText(
            message,
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Courier',
              height: 1.2,
            ),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text('Close'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          CupertinoDialogAction(
            child: Text('Refresh'),
            onPressed: () {
              Navigator.of(ctx).pop();
              _checkEntitlementStatus().then((_) => _debugPrintEntitlements());
            },
          ),
        ],
      ),
    );
  }

  Future<void> _simulatePremiumPurchase() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('premiumActive', true);
    await prefs.setString('premium_purchaseDate', DateTime.now().toIso8601String());

    setState(() {
      _entitlementStatus = {'premium': true};
    });

    _showSuccessDialog("DEBUG: Premium entitlement activated");
    await _debugPrintEntitlements();
  }

  Future<void> _resetPurchases() async {
    _removeAllActiveKeys();
  }

  void _showPurchaseSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.check_mark_circled_solid,
              color: Colors.green,
              size: 28,
            ),
            SizedBox(width: 8),
            Text('Thank You!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 16),
            Text(
              'Your purchase was successful.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'You now have access to all premium features.',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(
              'Continue',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(); // Return to previous screen
            },
          ),
        ],
      ),
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
    Package? selectedPackage = _packages.isEmpty ? null : _packages[0];

    return ListView(
      children: [
        _buildDebugPanel(),

        if (_packages.isEmpty)
          const Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'No products available. ${kDebugMode ? "\n\nTip: Check debug panel logs" : ""}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),

        if (selectedPackage != null)
          PremiumProductDisplay(
            entitlement: 'premium',
            packages: [selectedPackage],
            isEntitlementActive: _entitlementStatus.containsKey('premium'),
            onPurchase: _purchasePackage,
          ),

        // Restore Purchases Button
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

  Widget _buildDebugPanel() {
    if (!kDebugMode) return SizedBox.shrink();

    return Card(
      margin: EdgeInsets.all(8),
      child: ExpansionTile(
        initiallyExpanded: _isDebugExpanded,
        onExpansionChanged: (expanded) {
          setState(() => _isDebugExpanded = expanded);
        },
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('🛠️ Debug Tools',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            Text(
              _entitlementStatus['premium'] ?? false
                  ? "Premium ✓"
                  : "No Premium ✗",
              style: TextStyle(
                fontSize: 12,
                color: _entitlementStatus['premium'] ?? false
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                _debugButton(
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                  onPressed: _simulatePremiumPurchase,
                  tooltip: 'Simulate Premium',
                ),
                _debugButton(
                  icon: Icons.restore,
                  color: Colors.red,
                  onPressed: _resetPurchases,
                  tooltip: 'Reset Local',
                ),
                _debugButton(
                  icon: Icons.cloud_off,
                  color: Colors.orange,
                  onPressed: () async {
                    try {
                      showLoadingDialog('Revoking entitlements...');
                      await Purchases.invalidateCustomerInfoCache();
                      await _checkEntitlementStatus();
                      Navigator.of(context).pop(); // Dismiss loading
                      _showSuccessDialog('RevenueCat cache invalidated');
                    } catch (e) {
                      Navigator.of(context).pop(); // Dismiss loading
                      _showErrorDialog('Failed to invalidate: $e');
                    }
                  },
                  tooltip: 'Revoke RC Access',
                ),
                _debugButton(
                  icon: Icons.info_outline,
                  color: Colors.blue,
                  onPressed: () async {
                    await _debugPrintEntitlements();
                    await _debugPrintOfferings();
                  },
                  tooltip: 'Print Info',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _debugButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: EdgeInsets.all(8),
            child: Icon(icon, size: 20, color: color),
          ),
        ),
      ),
    );
  }
}
