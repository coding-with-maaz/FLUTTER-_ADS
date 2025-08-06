import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../managers/app_open_ad_manager.dart';

/// Listens for app foreground events and shows app open ads.
class AppLifecycleReactor {
  static final AppLifecycleReactor _instance = AppLifecycleReactor._internal();
  factory AppLifecycleReactor() => _instance;
  AppLifecycleReactor._internal();

  final AppOpenAdManager _appOpenAdManager = AppOpenAdManager();
  bool _isListening = false;

  /// Start listening to app state changes
  void startListening() {
    if (_isListening) {
      if (kDebugMode) {
        print('AppLifecycleReactor: Already listening to app state changes');
      }
      return;
    }

    if (kDebugMode) {
      print('AppLifecycleReactor: Starting to listen to app state changes');
    }

    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream.listen(_onAppStateChanged);
    _isListening = true;
  }

  /// Stop listening to app state changes
  void stopListening() {
    if (!_isListening) {
      if (kDebugMode) {
        print('AppLifecycleReactor: Not currently listening to app state changes');
      }
      return;
    }

    if (kDebugMode) {
      print('AppLifecycleReactor: Stopping listening to app state changes');
    }

    AppStateEventNotifier.stopListening();
    _isListening = false;
  }

  /// Handle app state changes
  void _onAppStateChanged(AppState appState) {
    if (kDebugMode) {
      print('AppLifecycleReactor: App state changed to: $appState');
    }

    switch (appState) {
      case AppState.foreground:
        _onAppForegrounded();
        break;
      case AppState.background:
        _onAppBackgrounded();
        break;
    }
  }

  /// Handle app coming to foreground
  void _onAppForegrounded() {
    if (kDebugMode) {
      print('AppLifecycleReactor: App came to foreground, attempting to show app open ad');
    }
    
    // Show app open ad when app comes to foreground
    _appOpenAdManager.showAdIfAvailable();
  }

  /// Handle app going to background
  void _onAppBackgrounded() {
    if (kDebugMode) {
      print('AppLifecycleReactor: App went to background');
    }
    
    // You can add any background-specific logic here
    // For example, preload ads, save state, etc.
  }

  /// Check if currently listening to app state changes
  bool get isListening => _isListening;

  /// Get the app open ad manager instance
  AppOpenAdManager get appOpenAdManager => _appOpenAdManager;

  /// Initialize app lifecycle reactor
  /// This should be called early in app initialization
  void initialize() {
    if (kDebugMode) {
      print('AppLifecycleReactor: Initializing');
    }

    // Start listening to app state changes
    startListening();

    // Load initial app open ad
    _appOpenAdManager.loadAd();
  }

  /// Dispose resources
  void dispose() {
    if (kDebugMode) {
      print('AppLifecycleReactor: Disposing');
    }

    stopListening();
    _appOpenAdManager.dispose();
  }

  /// Get debug information
  Map<String, dynamic> getDebugInfo() {
    return {
      'isListening': _isListening,
      'appOpenAdManager': _appOpenAdManager.getDebugInfo(),
    };
  }
} 