import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/ad_constants.dart';
import '../managers/consent_manager.dart';
import '../utils/countdown_timer.dart';

/// Rewarded Interstitial Ad Screen demonstrating rewarded interstitial ads
class RewardedInterstitialAdScreen extends StatefulWidget {
  const RewardedInterstitialAdScreen({super.key});

  @override
  State<RewardedInterstitialAdScreen> createState() => _RewardedInterstitialAdScreenState();
}

class _RewardedInterstitialAdScreenState extends State<RewardedInterstitialAdScreen> {
  final CountdownTimer _countdownTimer = CountdownTimer();
  RewardedInterstitialAd? _rewardedInterstitialAd;
  bool _gamePaused = false;
  bool _gameOver = false;
  bool _isPrivacyOptionsRequired = false;
  int _coins = 0;

  @override
  void initState() {
    super.initState();
    _checkPrivacyOptionsRequired();
    _startNewGame();
    _loadAd();

    // Show an alert dialog when the timer reaches zero
    _countdownTimer.addListener(
      () => setState(() {
        if (_countdownTimer.isComplete) {
          showDialog(
            context: context,
            builder: (context) => _buildAdDialog(),
          );
          _coins += AdConstants.baseCoinsPerGame;
        }
      }),
    );
  }

  /// Check if privacy options entry point is required
  void _checkPrivacyOptionsRequired() async {
    if (await ConsentManager.instance.isPrivacyOptionsRequired()) {
      setState(() {
        _isPrivacyOptionsRequired = true;
      });
    }
  }

  void _startNewGame() {
    _countdownTimer.start();
    _gameOver = false;
    _gamePaused = false;
  }

  void _pauseGame() {
    if (_gameOver || _gamePaused) {
      return;
    }
    _countdownTimer.pause();
    _gamePaused = true;
  }

  void _resumeGame() {
    if (_gameOver || !_gamePaused) {
      return;
    }
    _countdownTimer.resume();
    _gamePaused = false;
  }

  void _showAdCallback() {
    _rewardedInterstitialAd?.show(
      onUserEarnedReward: (AdWithoutView view, RewardItem rewardItem) {
        if (kDebugMode) {
          print('RewardedInterstitialAd: User earned reward: ${rewardItem.amount}');
        }
        setState(() => _coins += rewardItem.amount.toInt());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewarded Interstitial Ads'),
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
                      Icons.video_settings,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Rewarded Interstitial Ads',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hybrid of rewarded and interstitial ads with automatic display',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Game Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'The Impossible Game',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Game Status
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _countdownTimer.isComplete
                                ? 'Game Over!'
                                : '${_countdownTimer.timeLeft} seconds left!',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _countdownTimer.isComplete 
                                  ? Theme.of(context).colorScheme.error
                                  : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Game Controls
                          if (_countdownTimer.isComplete)
                            ElevatedButton.icon(
                              onPressed: () {
                                _startNewGame();
                                _loadAd();
                              },
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Play Again'),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),

            // Coins Display Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.monetization_on,
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Coins',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$_coins',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
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
                      'About Rewarded Interstitial Ads',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '• Combines features of rewarded and interstitial ads\n'
                      '• Automatically shown when game ends\n'
                      '• Users can choose to watch for extra rewards\n'
                      '• Higher engagement than regular interstitial ads\n'
                      '• Great for gaming apps with natural break points',
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

  /// Build the ad dialog that appears when the game ends
  Widget _buildAdDialog() {
    return AlertDialog(
      title: const Text('Watch an ad for extra coins'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'You\'ve completed the game! Watch a video ad to earn additional coins.',
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.video_library,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Earn ${AdConstants.rewardAmount} extra coins',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('No Thanks'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            _showAdCallback();
          },
          child: const Text('Watch Ad'),
        ),
      ],
    );
  }

  /// Build app bar actions for ad inspector and privacy settings
  List<Widget> _buildAppBarActions() {
    final actions = <Widget>[
      IconButton(
        icon: const Icon(Icons.bug_report),
        onPressed: () {
          _pauseGame();
          MobileAds.instance.openAdInspector((error) {
            if (error != null) {
              if (kDebugMode) {
                print('Ad Inspector error: $error');
              }
            }
            _resumeGame();
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
            _pauseGame();
            ConsentManager.instance.showPrivacyOptionsForm((formError) {
              if (formError != null) {
                if (kDebugMode) {
                  print('Privacy form error: ${formError.message}');
                }
              }
              _resumeGame();
            });
          },
          tooltip: 'Privacy Settings',
        ),
      );
    }

    return actions;
  }

  /// Load a rewarded interstitial ad
  void _loadAd() async {
    // Check if we can request ads
    if (!await ConsentManager.instance.canRequestAds()) {
      if (kDebugMode) {
        print('RewardedInterstitialAd: Cannot request ads - consent not granted');
      }
      return;
    }

    RewardedInterstitialAd.load(
      adUnitId: AdConstants.rewardedInterstitialAdUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          if (kDebugMode) {
            print('RewardedInterstitialAd: Ad loaded successfully');
          }
          
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              if (kDebugMode) {
                print('RewardedInterstitialAd: Ad showed full screen content');
              }
            },
            onAdImpression: (ad) {
              if (kDebugMode) {
                print('RewardedInterstitialAd: Ad impression recorded');
              }
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              if (kDebugMode) {
                print('RewardedInterstitialAd: Failed to show full screen content: $err');
              }
              ad.dispose();
            },
            onAdDismissedFullScreenContent: (ad) {
              if (kDebugMode) {
                print('RewardedInterstitialAd: Ad dismissed full screen content');
              }
              ad.dispose();
            },
            onAdClicked: (ad) {
              if (kDebugMode) {
                print('RewardedInterstitialAd: Ad clicked');
              }
            },
          );

          _rewardedInterstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          if (kDebugMode) {
            print('RewardedInterstitialAd: Failed to load ad: $error');
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _rewardedInterstitialAd?.dispose();
    _countdownTimer.dispose();
    super.dispose();
  }
} 