
import 'dart:io';
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

  @override
  void initState() {
    super.initState();
    _checkPremiumStatusAndLoadAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _checkPremiumStatusAndLoadAd() async {
    final prefs = await SharedPreferences.getInstance();
    // Use the premium status check you provided
    _isPremiumUser = prefs.getBool('isPremiumActive') ?? false;
    _isPremiumUser = false;

    if (!_isPremiumUser) {
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
    // Do not display the ad widget if the user has premium status.
    if (_isPremiumUser) {
      return SizedBox.shrink(); // Return an empty widget for premium users.
    }

    return SafeArea(
      child: Container(
        width: widget.adSize.width.toDouble(),
        height: widget.adSize.height.toDouble(),
        child: _bannerAd == null
            ? SizedBox.shrink() // Optionally, you can add a placeholder here.
            : AdWidget(ad: _bannerAd!),
      ),
    );
  }
}
