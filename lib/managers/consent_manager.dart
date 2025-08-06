import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

typedef OnConsentGatheringCompleteListener = void Function(FormError? error);

/// The Google Mobile Ads SDK provides the User Messaging Platform (Google's IAB
/// Certified consent management platform) as one solution to capture consent for
/// users in GDPR impacted countries. This is an example and you can choose
/// another consent management platform to capture consent.
class ConsentManager {
  // Singleton pattern
  ConsentManager._();
  static final ConsentManager _instance = ConsentManager._();
  static ConsentManager get instance => _instance;

  bool _isInitialized = false;
  
  /// Helper variable to determine if the app can request ads.
  Future<bool> canRequestAds() async {
    return await ConsentInformation.instance.canRequestAds();
  }

  /// Helper variable to determine if the privacy options form is required.
  Future<bool> isPrivacyOptionsRequired() async {
    return await ConsentInformation.instance
            .getPrivacyOptionsRequirementStatus() ==
        PrivacyOptionsRequirementStatus.required;
  }

  /// Check if consent manager is initialized
  bool get isInitialized => _isInitialized;

  /// Get current consent status
  Future<ConsentStatus> getConsentStatus() async {
    return ConsentInformation.instance.getConsentStatus();
  }

  /// Reset consent information (useful for testing)
  Future<void> resetConsentInfo() async {
    await ConsentInformation.instance.reset();
    _isInitialized = false;
    if (kDebugMode) {
      print('ConsentManager: Consent information reset');
    }
  }

  /// Helper method to call the Mobile Ads SDK to request consent information
  /// and load/show a consent form if necessary.
  void gatherConsent(
    OnConsentGatheringCompleteListener onConsentGatheringCompleteListener, {
    bool forceEEA = false, // For testing purposes
  }) {
    if (kDebugMode) {
      print('ConsentManager: Starting consent gathering process');
    }

    // For testing purposes, you can force a DebugGeography of EEA or NotEEA.
    ConsentDebugSettings debugSettings = ConsentDebugSettings(
      debugGeography: forceEEA 
          ? DebugGeography.debugGeographyEea 
          : DebugGeography.debugGeographyDisabled,
    );
    
    ConsentRequestParameters params = ConsentRequestParameters(
      consentDebugSettings: debugSettings,
    );

    // Requesting an update to consent information should be called on every app launch.
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        if (kDebugMode) {
          print('ConsentManager: Consent info update successful');
          print('ConsentManager: Can request ads: ${await canRequestAds()}');
          print('ConsentManager: Privacy options required: ${await isPrivacyOptionsRequired()}');
        }

        _isInitialized = true;

        ConsentForm.loadAndShowConsentFormIfRequired((loadAndShowError) {
          if (loadAndShowError != null) {
            if (kDebugMode) {
              print('ConsentManager: Error loading/showing consent form: ${loadAndShowError.message}');
            }
          } else {
            if (kDebugMode) {
              print('ConsentManager: Consent form loaded and shown successfully');
            }
          }
          
          // Consent has been gathered.
          onConsentGatheringCompleteListener(loadAndShowError);
        });
      },
      (FormError formError) {
        if (kDebugMode) {
          print('ConsentManager: Error requesting consent info update: ${formError.message}');
        }
        onConsentGatheringCompleteListener(formError);
      },
    );
  }

  /// Helper method to call the Mobile Ads SDK method to show the privacy options form.
  void showPrivacyOptionsForm(
    OnConsentFormDismissedListener onConsentFormDismissedListener,
  ) {
    if (kDebugMode) {
      print('ConsentManager: Showing privacy options form');
    }
    
    ConsentForm.showPrivacyOptionsForm(onConsentFormDismissedListener);
  }

  /// Check if we're in a GDPR-affected region
  Future<bool> isGDPRApplicable() async {
    final status = await ConsentInformation.instance.getConsentStatus();
    return status != ConsentStatus.notRequired;
  }

  /// Get detailed consent information for debugging
  Future<Map<String, dynamic>> getConsentDebugInfo() async {
    return {
      'isInitialized': _isInitialized,
      'canRequestAds': await canRequestAds(),
      'consentStatus': (await getConsentStatus()).toString(),
      'privacyOptionsRequired': await isPrivacyOptionsRequired(),
      'isGDPRApplicable': await isGDPRApplicable(),
    };
  }

  /// Initialize consent with error handling and retry logic
  Future<void> initializeConsent({
    bool forceEEA = false,
    int maxRetries = 3,
  }) async {
    int retryCount = 0;
    
    while (retryCount < maxRetries && !_isInitialized) {
      try {
        final completer = Completer<FormError?>();
        
        gatherConsent(
          (error) => completer.complete(error),
          forceEEA: forceEEA,
        );
        
        final error = await completer.future;
        
        if (error == null) {
          if (kDebugMode) {
            print('ConsentManager: Consent initialization successful');
          }
          break;
        } else {
          if (kDebugMode) {
            print('ConsentManager: Consent initialization failed: ${error.message}');
          }
          retryCount++;
          
          if (retryCount < maxRetries) {
            await Future.delayed(Duration(seconds: retryCount * 2));
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('ConsentManager: Exception during consent initialization: $e');
        }
        retryCount++;
        
        if (retryCount < maxRetries) {
          await Future.delayed(Duration(seconds: retryCount * 2));
        }
      }
    }
    
    if (!_isInitialized && kDebugMode) {
      print('ConsentManager: Failed to initialize consent after $maxRetries attempts');
    }
  }
} 