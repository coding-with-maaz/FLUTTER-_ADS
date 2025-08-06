import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/ad_constants.dart';
import '../managers/consent_manager.dart';

/// Native Ad Screen demonstrating native template ads
class NativeAdScreen extends StatefulWidget {
  const NativeAdScreen({super.key});

  @override
  State<NativeAdScreen> createState() => _NativeAdScreenState();
}

class _NativeAdScreenState extends State<NativeAdScreen> {
  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;
  bool _isPrivacyOptionsRequired = false;

  // Native template aspect ratio for medium template
  final double _adAspectRatioMedium = AdConstants.nativeTemplateAspectRatio;

  @override
  void initState() {
    super.initState();
    _checkPrivacyOptionsRequired();
    _loadAd();
  }

  /// Check if privacy options entry point is required
  void _checkPrivacyOptionsRequired() async {
    if (await ConsentManager.instance.isPrivacyOptionsRequired()) {
      setState(() {
        _isPrivacyOptionsRequired = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Native Ads'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: _buildAppBarActions(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.article,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Native Template Ads',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Native ads blend seamlessly with your app content using Google\'s template system',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Native Ad Container
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Native Template Ad',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Native Ad Display Area
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.width * _adAspectRatioMedium,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _nativeAdIsLoaded && _nativeAd != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: AdWidget(ad: _nativeAd!),
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.ads_click,
                                    size: 48,
                                    color: Theme.of(context).colorScheme.outline,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Loading Native Ad...',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.outline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Control Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _loadAd,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Load New Ad'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _nativeAdIsLoaded ? _showAdInfo : null,
                            icon: const Icon(Icons.info_outline),
                            label: const Text('Ad Info'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),

            // Information Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About Native Template Ads',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '• Native template ads use Google\'s pre-built templates\n'
                      '• They automatically adapt to your app\'s theme\n'
                      '• Customizable colors, fonts, and styling\n'
                      '• Seamless integration with app content\n'
                      '• Better user experience than traditional banner ads',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build app bar actions for ad inspector and privacy settings
  List<Widget> _buildAppBarActions() {
    final actions = <Widget>[
      IconButton(
        icon: const Icon(Icons.bug_report),
        onPressed: () {
          MobileAds.instance.openAdInspector((error) {
            if (error != null) {
              if (kDebugMode) {
                print('Ad Inspector error: $error');
              }
            }
          });
        },
        tooltip: 'Ad Inspector',
      ),
    ];

    if (_isPrivacyOptionsRequired) {
      actions.add(
        IconButton(
          icon: const Icon(Icons.privacy_tip),
          onPressed: () {
            ConsentManager.instance.showPrivacyOptionsForm((formError) {
              if (formError != null) {
                if (kDebugMode) {
                  print('Privacy form error: ${formError.message}');
                }
              }
            });
          },
          tooltip: 'Privacy Settings',
        ),
      );
    }

    return actions;
  }

  /// Load a native ad
  void _loadAd() async {
    // Check if we can request ads
    if (!await ConsentManager.instance.canRequestAds()) {
      if (kDebugMode) {
        print('NativeAd: Cannot request ads - consent not granted');
      }
      return;
    }

    setState(() {
      _nativeAdIsLoaded = false;
    });

    // Dispose of previous ad
    _nativeAd?.dispose();

    _nativeAd = NativeAd(
      adUnitId: AdConstants.nativeAdUnitId,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (kDebugMode) {
            print('NativeAd: Ad loaded successfully');
          }
          setState(() {
            _nativeAdIsLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          if (kDebugMode) {
            print('NativeAd: Failed to load ad: $error');
          }
          ad.dispose();
          setState(() {
            _nativeAdIsLoaded = false;
          });
        },
        onAdClicked: (ad) {
          if (kDebugMode) {
            print('NativeAd: Ad clicked');
          }
        },
        onAdImpression: (ad) {
          if (kDebugMode) {
            print('NativeAd: Ad impression recorded');
          }
        },
        onAdClosed: (ad) {
          if (kDebugMode) {
            print('NativeAd: Ad closed');
          }
        },
        onAdOpened: (ad) {
          if (kDebugMode) {
            print('NativeAd: Ad opened');
          }
        },
        onAdWillDismissScreen: (ad) {
          if (kDebugMode) {
            print('NativeAd: Ad will dismiss screen');
          }
        },
        onPaidEvent: (ad, valueMicros, precision, currencyCode) {
          if (kDebugMode) {
            print('NativeAd: Paid event - $valueMicros $currencyCode');
          }
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: Theme.of(context).colorScheme.surface,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Theme.of(context).colorScheme.onSurface,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Theme.of(context).colorScheme.onSurface,
          style: NativeTemplateFontStyle.italic,
          size: 14.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: Theme.of(context).colorScheme.onSurface,
          style: NativeTemplateFontStyle.normal,
          size: 12.0,
        ),
      ),
    )..load();
  }

  /// Show ad information dialog
  void _showAdInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Native Ad Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ad Unit ID: ${AdConstants.nativeAdUnitId}'),
            const SizedBox(height: 8),
            Text('Template Type: Medium'),
            const SizedBox(height: 8),
            Text('Status: ${_nativeAdIsLoaded ? 'Loaded' : 'Not Loaded'}'),
            const SizedBox(height: 8),
            const Text('This native ad uses Google\'s template system for seamless integration.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }
} 