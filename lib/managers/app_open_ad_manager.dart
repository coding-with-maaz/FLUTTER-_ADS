import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/ad_constants.dart';
import 'consent_manager.dart';

/// Utility class that manages loading and showing app open ads.
class AppOpenAdManager {
  // Singleton pattern
  static final AppOpenAdManager _instance = AppOpenAdManager._internal();
  factory AppOpenAdManager() => _instance;
  AppOpenAdManager._internal();

  /// Keep track of load time so we don't show an expired ad.
  DateTime? _appOpenLoadTime;

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  bool _isLoadingAd = false;

  /// Whether an ad is available to be shown.
  bool get isAdAvailable {
    return _appOpenAd != null && !_isAdExpired;
  }

  /// Whether the app open ad is currently being shown.
  bool get isShowingAd => _isShowingAd;

  /// Whether an ad is currently being loaded.
  bool get isLoadingAd => _isLoadingAd;

  /// Check if the cached ad has expired.
  bool get _isAdExpired {
    if (_appOpenLoadTime == null) return true;
    
    return DateTime.now().subtract(AdConstants.appOpenAdMaxCacheDuration)
        .isAfter(_appOpenLoadTime!);
  }

  /// Load an [AppOpenAd].
  Future<void> loadAd() async {
    // Don't load if already loading
    if (_isLoadingAd) {
      if (kDebugMode) {
        print('AppOpenAdManager: Ad is already loading, skipping');
      }
      return;
    }

    // Don't load if ad is available and not expired
    if (isAdAvailable) {
      if (kDebugMode) {
        print('AppOpenAdManager: Ad is already available and not expired');
      }
      return;
    }

    // Only load an ad if the Mobile Ads SDK has gathered consent aligned with
    // the app's configured messages.
    var canRequestAds = await ConsentManager.instance.canRequestAds();
    if (!canRequestAds) {
      if (kDebugMode) {
        print('AppOpenAdManager: Cannot request ads due to consent status');
      }
      return;
    }

    _isLoadingAd = true;

    if (kDebugMode) {
      print('AppOpenAdManager: Loading app open ad...');
    }

    AppOpenAd.load(
      adUnitId: AdConstants.appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          if (kDebugMode) {
            print('AppOpenAdManager: $ad loaded successfully');
          }
          _appOpenLoadTime = DateTime.now();
          _appOpenAd = ad;
          _isLoadingAd = false;
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            print('AppOpenAdManager: Failed to load app open ad: $error');
          }
          _isLoadingAd = false;
        },
      ),
    );
  }

  /// Shows the ad, if one exists and is not already being shown.
  ///
  /// If the previously cached ad has expired, this just loads and caches a
  /// new ad.
  void showAdIfAvailable() {
    // Don't show if consent is not available
    ConsentManager.instance.canRequestAds().then((canRequestAds) {
      if (!canRequestAds) {
        if (kDebugMode) {
          print('AppOpenAdManager: Cannot show ad due to consent status');
        }
        return;
      }

      if (!isAdAvailable) {
        if (kDebugMode) {
          print('AppOpenAdManager: Tried to show ad before available. Loading new ad.');
        }
        loadAd();
        return;
      }

      if (_isShowingAd) {
        if (kDebugMode) {
          print('AppOpenAdManager: Tried to show ad while already showing an ad.');
        }
        return;
      }

      if (_isAdExpired) {
        if (kDebugMode) {
          print('AppOpenAdManager: Maximum cache duration exceeded. Loading another ad.');
        }
        _appOpenAd!.dispose();
        _appOpenAd = null;
        loadAd();
        return;
      }

      if (kDebugMode) {
        print('AppOpenAdManager: Showing app open ad');
      }

      // Set the fullScreenContentCallback and show the ad.
      _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          _isShowingAd = true;
          if (kDebugMode) {
            print('AppOpenAdManager: $ad onAdShowedFullScreenContent');
          }
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          if (kDebugMode) {
            print('AppOpenAdManager: $ad onAdFailedToShowFullScreenContent: $error');
          }
          _isShowingAd = false;
          ad.dispose();
          _appOpenAd = null;
          loadAd(); // Load a new ad
        },
        onAdDismissedFullScreenContent: (ad) {
          if (kDebugMode) {
            print('AppOpenAdManager: $ad onAdDismissedFullScreenContent');
          }
          _isShowingAd = false;
          ad.dispose();
          _appOpenAd = null;
          loadAd(); // Load a new ad for next time
        },
        onAdImpression: (ad) {
          if (kDebugMode) {
            print('AppOpenAdManager: $ad recorded an impression');
          }
        },
        onAdClicked: (ad) {
          if (kDebugMode) {
            print('AppOpenAdManager: $ad was clicked');
          }
        },
      );

      _appOpenAd!.show();
    });
  }

  /// Dispose the current ad and reset state.
  void dispose() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
    _isShowingAd = false;
    _isLoadingAd = false;
    _appOpenLoadTime = null;
    
    if (kDebugMode) {
      print('AppOpenAdManager: Disposed');
    }
  }

  /// Get debug information about the current ad state.
  Map<String, dynamic> getDebugInfo() {
    return {
      'isAdAvailable': isAdAvailable,
      'isShowingAd': _isShowingAd,
      'isLoadingAd': _isLoadingAd,
      'isAdExpired': _isAdExpired,
      'loadTime': _appOpenLoadTime?.toIso8601String(),
      'adUnitId': AdConstants.appOpenAdUnitId,
    };
  }
} 