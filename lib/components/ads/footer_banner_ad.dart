import 'package:chronolog/components/premium/premium_list_item.dart';
import 'package:chronolog/screens/purchase_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

// A reusable footer banner ad widget.
class FooterBannerAdWidget extends StatefulWidget {
  final AdSize adSize;
  final String adUnitId;

  const FooterBannerAdWidget({
    Key? key,
    this.adSize = AdSize.banner,
    this.adUnitId = 'ca-app-pub-3836871285810522/1271162483',
  }) : super(key: key);

  @override
  _FooterBannerAdWidgetState createState() => _FooterBannerAdWidgetState();
}

class _FooterBannerAdWidgetState extends State<FooterBannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isPremiumUser = false;
  bool _isOpenedMoreThanTwo = false;

  @override
  void initState() {
    super.initState();
    _checkStatusesAndLoadAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<bool> _isPremiumActivated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isPremiumActive') ?? false;
  }

  Future<void> _checkStatusesAndLoadAd() async {
    final prefs = await SharedPreferences.getInstance();

    int openCount = prefs.getInt('openCount') ?? 0;
    // Use the premium status check you provided
    _isPremiumUser = prefs.getBool('isPremiumActive') ?? false;
    _isOpenedMoreThanTwo = openCount > 2;
    // for testing
    // _isPremiumUser = false;

    if (!_isPremiumUser && _isOpenedMoreThanTwo) {
      _loadAd();
    }
  }

  void _loadAd() {
    final bannerAd = BannerAd(
      size: widget.adSize,
      adUnitId: widget.adUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd?;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    );

    // Start loading the ad.
    bannerAd.load();
  }

  @override
  Widget build(BuildContext context) {
    // Check if the user is premium or hasn't opened the app more than two times.
    if (_isPremiumUser || !_isOpenedMoreThanTwo) {
      return SizedBox.shrink(); // Return an empty widget in these cases.
    }

    // If the conditions are not met (non-premium user and opened more than two times), show the ad.
    return SafeArea(
      child: Column(
        children: [
          MiniPremiumButton(
            isPremiumActivated: _isPremiumActivated,
            onTapPremium: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PurchaseScreen()),
              );
            },
          ),
          SizedBox(height: 8),
          Container(
            width: widget.adSize.width.toDouble(),
            height: widget.adSize.height.toDouble(),
            child: _bannerAd == null
                ? SizedBox
                    .shrink() // Optionally, you can add a placeholder here.
                : AdWidget(ad: _bannerAd!),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}
