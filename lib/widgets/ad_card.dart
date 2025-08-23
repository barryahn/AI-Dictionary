import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdCard extends StatefulWidget {
  const AdCard({super.key});

  @override
  State<AdCard> createState() => _AdCardState();
}

class _AdCardState extends State<AdCard> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  String get _adUnitId {
    if (Platform.isAndroid) {
      // Android 테스트 배너 광고 단위 ID
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      // iOS 테스트 배너 광고 단위 ID
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    // 기타 플랫폼은 광고 미지원
    return '';
  }

  @override
  void initState() {
    super.initState();
    if (_adUnitId.isNotEmpty) {
      _bannerAd = BannerAd(
        size: AdSize.mediumRectangle,
        adUnitId: _adUnitId,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (!mounted) return;
            setState(() {
              _isLoaded = true;
            });
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
          },
        ),
        request: const AdRequest(),
      )..load();
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    final adSize = _bannerAd!.size;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Material(
          elevation: 0,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: adSize.width.toDouble(),
            height: adSize.height.toDouble(),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AdWidget(ad: _bannerAd!),
            ),
          ),
        ),
      ),
    );
  }
}
