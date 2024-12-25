import 'package:chronolog/components/premium/premium_list_item.dart';
import 'package:chronolog/screens/purchase_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

// A reusable footer banner ad widget.
class FooterBannerAdWidget extends StatefulWidget {
  final double bottomPadding;
  
  const FooterBannerAdWidget({
    Key? key,
    this.bottomPadding = 16.0,  // Default padding that can be overridden
  }) : super(key: key);

  @override
  _FooterBannerAdWidgetState createState() => _FooterBannerAdWidgetState();
}

class _FooterBannerAdWidgetState extends State<FooterBannerAdWidget> {
  bool _isPremiumUser = false;

  @override
  void initState() {
    super.initState();
    _checkPremiumStatus();
  }

  Future<void> _checkPremiumStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isPremiumUser = prefs.getBool('in_app_premiumActive') == true ||
                     prefs.getBool('in_app_luxuryActive') == true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_isPremiumUser) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: widget.bottomPadding,
        left: 16.0,
        right: 16.0,
      ),
      child: SafeArea(
        child: ElevatedButton(
          style: Theme.of(context).elevatedButtonTheme.style,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PurchaseScreen()),
            );
          },
          child: Text(
            'Upgrade to Premium',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
