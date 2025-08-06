import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/ad_constants.dart';
import '../managers/consent_manager.dart';
import '../utils/countdown_timer.dart';

/// Rewarded Ad Screen demonstrating rewarded video ads
class RewardedAdScreen extends StatefulWidget {
  const RewardedAdScreen({super.key});

  @override
  State<RewardedAdScreen> createState() => _RewardedAdScreenState();
}

class _RewardedAdScreenState extends State<RewardedAdScreen> {
  final CountdownTimer _countdownTimer = CountdownTimer();
  RewardedAd? _rewardedAd;
  bool _showWatchVideoButton = false;
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

    // Show the "Watch video" button when the timer reaches zero
    _countdownTimer.addListener(
      () => setState(() {
        if (_countdownTimer.isComplete) {
          _gameOver = true;
          _showWatchVideoButton = true;
          _coins += AdConstants.baseCoinsPerGame;
        } else {
          _showWatchVideoButton = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewarded Ads'),
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
                      Icons.video_library,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Rewarded Video Ads',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Users watch video ads to earn in-app rewards',
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
                          
                          if (_showWatchVideoButton)
                            ElevatedButton.icon(
                              onPressed: _showRewardedAd,
                              icon: const Icon(Icons.video_library),
                              label: Text('Watch Video for ${AdConstants.rewardAmount} Coins'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.tertiary,
                                foregroundColor: Theme.of(context).colorScheme.onTertiary,
                              ),
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
                      'About Rewarded Ads',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '• Users voluntarily watch video ads\n'
                      '• Rewards are given after video completion\n'
                      '• Higher engagement than other ad formats\n'
                      '• Great for gaming and utility apps\n'
                      '• Users must be able to skip after 5 seconds',
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

  /// Load a rewarded ad
  void _loadAd() async {
    // Check if we can request ads
    if (!await ConsentManager.instance.canRequestAds()) {
      if (kDebugMode) {
        print('RewardedAd: Cannot request ads - consent not granted');
      }
      return;
    }

    RewardedAd.load(
      adUnitId: AdConstants.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          if (kDebugMode) {
            print('RewardedAd: Ad loaded successfully');
          }
          
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              if (kDebugMode) {
                print('RewardedAd: Ad showed full screen content');
              }
            },
            onAdImpression: (ad) {
              if (kDebugMode) {
                print('RewardedAd: Ad impression recorded');
              }
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              if (kDebugMode) {
                print('RewardedAd: Failed to show full screen content: $err');
              }
              ad.dispose();
            },
            onAdDismissedFullScreenContent: (ad) {
              if (kDebugMode) {
                print('RewardedAd: Ad dismissed full screen content');
              }
              ad.dispose();
            },
            onAdClicked: (ad) {
              if (kDebugMode) {
                print('RewardedAd: Ad clicked');
              }
            },
          );

          _rewardedAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          if (kDebugMode) {
            print('RewardedAd: Failed to load ad: $error');
          }
        },
      ),
    );
  }

  /// Show the rewarded ad
  void _showRewardedAd() {
    setState(() => _showWatchVideoButton = false);

    _rewardedAd?.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
        if (kDebugMode) {
          print('RewardedAd: User earned reward: ${rewardItem.amount}');
        }
        setState(() => _coins += rewardItem.amount.toInt());
      },
    );
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    _countdownTimer.dispose();
    super.dispose();
  }
} 