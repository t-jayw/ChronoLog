import 'package:chronolog/components/premium/premium_list_item.dart';
import 'package:chronolog/screens/purchase_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

// A reusable footer banner ad widget.
class FooterBannerAdWidget extends StatefulWidget {
  const FooterBannerAdWidget({
    Key? key,
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

    return SafeArea(
      child: Column(
        children: [
          PremiumButton(
            isPremiumActivated: () async => _isPremiumUser,
            onTapPremium: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PurchaseScreen()),
              );
            },
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}
