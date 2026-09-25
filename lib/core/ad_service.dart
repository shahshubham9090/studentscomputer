import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized || kIsWeb) return;
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint("AdMob Initialized");
    } catch (e) {
      debugPrint("AdMob Initialization Failed: $e");
    }
  }

  // Debug builds use Google's test IDs so clicking our own ads during
  // development can't get the AdMob account flagged.
  static String get bannerAdUnitId {
    if (kIsWeb) return ''; // Ads not supported on web via this plugin

    if (defaultTargetPlatform == TargetPlatform.android) {
      return kDebugMode
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-1477676833337384/9022710324';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      // TODO: replace with the real iOS banner ID before releasing on iOS.
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    return '';
  }
}
