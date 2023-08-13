import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../components/premium_features.dart';

import 'package:shared_preferences/shared_preferences.dart';

Future<void> _setPremiumActive(bool value) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool('premiumActive', value);
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




  @override
  void initState() {
    super.initState();
    _fetchAvailablePackages();
    _checkPurchasedStatus();


    _checkPremiumStatus();

  }


  Future<void> _checkPremiumStatus() async {
    print('checking prem status');
    final prefs = await SharedPreferences.getInstance();
    bool isPremium = prefs.getBool('premiumActive') ?? false;
    print(isPremium);
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

  Future<void> _checkPurchasedStatus() async {
    // try {
    //   final CustomerInfo customerInfo = await Purchases.getCustomerInfo();
    //   print(customerInfo);
    //   if (customerInfo.entitlements.active.containsKey('premium')) {
    //     setState(() {
    //       _hasPurchased = true;
    //     });
    //   }
    // } catch (e) {
    //   print("Error fetching purchaser info: $e");
    // }
  }

  Future<void> _purchasePackage(Package package) async {
    print('here');
    try {
      final purchaseResult = await Purchases.purchasePackage(package);
      print(purchaseResult);
      if (purchaseResult.entitlements.active.isNotEmpty) {
          await _setPremiumActive(true);


        // Grant access to the purchased feature
        // Maybe display a success message?
      }
    } catch (e) {
      print("Purchase error: $e");
      // Handle error. Maybe display an error message?
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Premium')),
      body: _loadingPackages
          ? _buildLoadingIndicator()
          : _buildPackageList(),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(child: CircularProgressIndicator());
  }

  Widget _buildPackageList() {
    return ListView.builder(
      itemCount: _packages.length,
      itemBuilder: (context, index) {
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
            ) else ListTile(
              title: Text(package.storeProduct.title),
              subtitle: Text(package.storeProduct.description),
              trailing: ElevatedButton(
                onPressed: () => _purchasePackage(package),
                child: Text('Unlock'),
                
              ),
              leading: Text(package.storeProduct.priceString),
            ),
          ],
        );
      },
    );
  }
}
