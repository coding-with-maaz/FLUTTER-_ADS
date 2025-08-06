import 'dart:io';

/// AdMob Ad Unit IDs and Configuration Constants
class AdConstants {
  // Private constructor to prevent instantiation
  AdConstants._();

  // ============================================================================
  // APP OPEN AD UNIT IDs
  // ============================================================================
  static String get appOpenAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/9257395921' // Android test ID
      : 'ca-app-pub-3940256099942544/5575463023'; // iOS test ID

  // ============================================================================
  // BANNER AD UNIT IDs
  // ============================================================================
  static String get bannerAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/9214589741' // Android test ID
      : 'ca-app-pub-3940256099942544/2435281174'; // iOS test ID

  // ============================================================================
  // INTERSTITIAL AD UNIT IDs
  // ============================================================================
  static String get interstitialAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712' // Android test ID
      : 'ca-app-pub-3940256099942544/4411468910'; // iOS test ID

  // ============================================================================
  // NATIVE AD UNIT IDs
  // ============================================================================
  static String get nativeAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/2247696110' // Android test ID
      : 'ca-app-pub-3940256099942544/3986624511'; // iOS test ID

  // ============================================================================
  // REWARDED AD UNIT IDs
  // ============================================================================
  static String get rewardedAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917' // Android test ID
      : 'ca-app-pub-3940256099942544/1712485313'; // iOS test ID

  // ============================================================================
  // REWARDED INTERSTITIAL AD UNIT IDs
  // ============================================================================
  static String get rewardedInterstitialAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5354046379' // Android test ID
      : 'ca-app-pub-3940256099942544/6978759866'; // iOS test ID

  // ============================================================================
  // AD CONFIGURATION
  // ============================================================================
  
  /// Maximum cache duration for app open ads (4 hours)
  static const Duration appOpenAdMaxCacheDuration = Duration(hours: 4);
  
  /// Game duration for rewarded ad examples (5 seconds)
  static const int gameCountdownSeconds = 5;
  
  /// Reward amount for rewarded ads
  static const int rewardAmount = 10;
  
  /// Base coins earned per game completion
  static const int baseCoinsPerGame = 1;
  
  /// Native ad factory ID for platform-specific implementation
  static const String nativeAdFactoryId = 'adFactoryExample';
  
  /// Native ad height for Android
  static const double nativeAdHeightAndroid = 320.0;
  
  /// Native ad height for iOS
  static const double nativeAdHeightIOS = 300.0;
  
  /// Get platform-specific native ad height
  static double get nativeAdHeight => Platform.isAndroid 
      ? nativeAdHeightAndroid 
      : nativeAdHeightIOS;
  
  /// Native template ad aspect ratio (medium template)
  static const double nativeTemplateAspectRatio = 370 / 355;

  // ============================================================================
  // PRODUCTION AD UNIT IDs (Replace with your actual ad unit IDs)
  // ============================================================================
  
  // TODO: Replace these with your actual AdMob ad unit IDs for production
  /*
  static String get appOpenAdUnitIdProduction => Platform.isAndroid
      ? 'ca-app-pub-YOUR_APP_ID/YOUR_APP_OPEN_AD_UNIT_ID' // Your Android app open ad unit
      : 'ca-app-pub-YOUR_APP_ID/YOUR_APP_OPEN_AD_UNIT_ID'; // Your iOS app open ad unit

  static String get bannerAdUnitIdProduction => Platform.isAndroid
      ? 'ca-app-pub-YOUR_APP_ID/YOUR_BANNER_AD_UNIT_ID' // Your Android banner ad unit
      : 'ca-app-pub-YOUR_APP_ID/YOUR_BANNER_AD_UNIT_ID'; // Your iOS banner ad unit

  // ... Add other production ad unit IDs
  */

  // ============================================================================
  // DEBUG SETTINGS
  // ============================================================================
  
  /// Enable debug logging for ads
  static const bool enableAdDebugLogging = true;
  
  /// Test device IDs (add your test device IDs here)
  static const List<String> testDeviceIds = [
    // Add your test device IDs here
    // 'YOUR_TEST_DEVICE_ID_HERE',
  ];
} 