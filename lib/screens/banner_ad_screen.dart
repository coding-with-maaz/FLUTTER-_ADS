import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/ad_constants.dart';
import '../managers/consent_manager.dart';

/// Screen demonstrating banner ads with adaptive sizing
class BannerAdScreen extends StatefulWidget {
  const BannerAdScreen({super.key});

  @override
  State<BannerAdScreen> createState() => _BannerAdScreenState();
}

class _BannerAdScreenState extends State<BannerAdScreen> {
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  Orientation? _currentOrientation;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  /// Load a banner ad
  Future<void> _loadAd() async {
    // Check consent before loading ad
    final canRequestAds = await ConsentManager.instance.canRequestAds();
    if (!canRequestAds) {
      if (kDebugMode) {
        print('BannerAdScreen: Cannot request ads due to consent status');
      }
      return;
    }

    if (!mounted) return;

    // Get adaptive banner ad size
    final AdSize? size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      MediaQuery.of(context).size.width.truncate(),
    );

    if (size == null) {
      if (kDebugMode) {
        print('BannerAdScreen: Unable to get width of anchored banner.');
      }
      return;
    }

    if (kDebugMode) {
      print('BannerAdScreen: Loading banner ad with size: ${size.width}x${size.height}');
    }

    _bannerAd = BannerAd(
      adUnitId: AdConstants.bannerAdUnitId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (kDebugMode) {
            print('BannerAdScreen: Banner ad loaded successfully');
          }
          if (mounted) {
            setState(() {
              _isBannerAdReady = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          if (kDebugMode) {
            print('BannerAdScreen: Banner ad failed to load: $error');
          }
          ad.dispose();
          if (mounted) {
            setState(() {
              _isBannerAdReady = false;
            });
          }
        },
        onAdOpened: (ad) {
          if (kDebugMode) {
            print('BannerAdScreen: Banner ad opened');
          }
        },
        onAdClosed: (ad) {
          if (kDebugMode) {
            print('BannerAdScreen: Banner ad closed');
          }
        },
        onAdImpression: (ad) {
          if (kDebugMode) {
            print('BannerAdScreen: Banner ad impression recorded');
          }
        },
        onAdClicked: (ad) {
          if (kDebugMode) {
            print('BannerAdScreen: Banner ad clicked');
          }
        },
        onAdWillDismissScreen: (ad) {
          if (kDebugMode) {
            print('BannerAdScreen: Banner ad will dismiss screen');
          }
        },
      ),
    );

    await _bannerAd!.load();
  }

  /// Refresh the banner ad
  void _refreshAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    setState(() {
      _isBannerAdReady = false;
    });
    _loadAd();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banner Ads'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAd,
            tooltip: 'Refresh Ad',
          ),
        ],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          // Reload ad if orientation changed
          if (_currentOrientation != orientation) {
            if (_currentOrientation != null) {
              _refreshAd();
            }
            _currentOrientation = orientation;
          }

          return Column(
            children: [
              // Main content area
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Info Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.view_stream,
                                    color: Colors.blue,
                                    size: 32,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Banner Ads',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Banner ads are rectangular image or text ads that occupy a spot within an app\'s layout. They stay on screen while users are interacting with the app.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 16),
                              _buildFeaturesList(),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Ad Status Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ad Status',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: _isBannerAdReady ? Colors.green : Colors.orange,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isBannerAdReady ? 'Ad Loaded' : 'Loading Ad...',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              if (_bannerAd != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Ad Size: ${_bannerAd!.size.width} x ${_bannerAd!.size.height}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  'Ad Unit ID: ${AdConstants.bannerAdUnitId}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Instructions
                      Card(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'How it works',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '• The banner ad is displayed at the bottom of the screen\n'
                                '• It uses adaptive sizing to fit different screen sizes\n'
                                '• The ad reloads when orientation changes\n'
                                '• Tap the refresh button to load a new ad',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Banner Ad Container
              if (_isBannerAdReady && _bannerAd != null)
                Container(
                  alignment: Alignment.center,
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Build features list
  Widget _buildFeaturesList() {
    final features = [
      'Adaptive sizing for all screen sizes',
      'Automatic orientation handling',
      'Minimal UI disruption',
      'High viewability rates',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Features:',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...features.map((feature) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: Text(
                  feature,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
} 