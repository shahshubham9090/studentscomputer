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
      if (kDebugMode) {
        print("AdMob Initialized");
      }
    } catch (e) {
      debugPrint("AdMob Initialization Failed: $e");
    }
  }

  // TEST IDs from Google
  static String get bannerAdUnitId {
    if (kIsWeb) return ''; // Ads not supported on web via this plugin
    
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'ca-app-pub-1477676833337384/9022710324';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    return '';
  }

  static String get interstitialAdUnitId {
    if (kIsWeb) return '';
    
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'ca-app-pub-3940256099942544/1033173712';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
    }
    return '';
  }
}
