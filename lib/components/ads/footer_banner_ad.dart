import 'package:chronolog/screens/purchase_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// A reusable footer banner ad widget.
class FooterBannerAdWidget extends StatefulWidget {
  final double bottomPadding;
  
  const FooterBannerAdWidget({
    Key? key,
    this.bottomPadding = 16.0,
  }) : super(key: key);

  @override
  _FooterBannerAdWidgetState createState() => _FooterBannerAdWidgetState();
}

class _FooterBannerAdWidgetState extends State<FooterBannerAdWidget> {
  bool _isPremiumUser = false;
  bool _shouldShowAd = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isPremiumUser = prefs.getBool('premiumActive') == true;
    int openCount = prefs.getInt('openCount') ?? 0;
    _shouldShowAd = openCount >= 1;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_isPremiumUser || !_shouldShowAd) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: widget.bottomPadding,
        left: 8.0,
        right: 8.0,
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
            'Upgrade to Premium!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
