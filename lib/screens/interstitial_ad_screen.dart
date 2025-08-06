import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/ad_constants.dart';
import '../managers/consent_manager.dart';
import '../utils/countdown_timer.dart';

/// Screen demonstrating interstitial ads with a simple game
class InterstitialAdScreen extends StatefulWidget {
  const InterstitialAdScreen({super.key});

  @override
  State<InterstitialAdScreen> createState() => _InterstitialAdScreenState();
}

class _InterstitialAdScreenState extends State<InterstitialAdScreen> {
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  late CountdownTimer _countdownTimer;
  bool _gamePaused = false;
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();
    _countdownTimer = CountdownTimer(AdConstants.gameCountdownSeconds);
    _loadAd();
    _startGame();
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    _countdownTimer.dispose();
    super.dispose();
  }

  /// Load an interstitial ad
  Future<void> _loadAd() async {
    // Check consent before loading ad
    final canRequestAds = await ConsentManager.instance.canRequestAds();
    if (!canRequestAds) {
      if (kDebugMode) {
        print('InterstitialAdScreen: Cannot request ads due to consent status');
      }
      return;
    }

    if (kDebugMode) {
      print('InterstitialAdScreen: Loading interstitial ad...');
    }

    InterstitialAd.load(
      adUnitId: AdConstants.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          if (kDebugMode) {
            print('InterstitialAdScreen: Interstitial ad loaded successfully');
          }
          
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (InterstitialAd ad) {
              if (kDebugMode) {
                print('InterstitialAdScreen: Ad showed full screen content');
              }
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              if (kDebugMode) {
                print('InterstitialAdScreen: Ad failed to show full screen content: $error');
              }
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialAdReady = false;
              _loadAd(); // Load a new ad
            },
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              if (kDebugMode) {
                print('InterstitialAdScreen: Ad dismissed full screen content');
              }
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialAdReady = false;
              _loadAd(); // Load a new ad for next time
            },
            onAdImpression: (InterstitialAd ad) {
              if (kDebugMode) {
                print('InterstitialAdScreen: Ad impression recorded');
              }
            },
            onAdClicked: (InterstitialAd ad) {
              if (kDebugMode) {
                print('InterstitialAdScreen: Ad was clicked');
              }
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          if (kDebugMode) {
            print('InterstitialAdScreen: Interstitial ad failed to load: $error');
          }
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  /// Start the game
  void _startGame() {
    _countdownTimer.addListener(_onTimerUpdate);
    _countdownTimer.start();
    setState(() {
      _gameOver = false;
      _gamePaused = false;
    });
  }

  /// Handle timer updates
  void _onTimerUpdate() {
    if (mounted) {
      setState(() {
        if (_countdownTimer.isComplete) {
          _gameOver = true;
          _showGameOverDialog();
        }
      });
    }
  }

  /// Pause the game
  void _pauseGame() {
    if (_gameOver || _gamePaused) return;
    
    _countdownTimer.pause();
    setState(() {
      _gamePaused = true;
    });
  }

  /// Resume the game
  void _resumeGame() {
    if (_gameOver || !_gamePaused) return;
    
    _countdownTimer.resume();
    setState(() {
      _gamePaused = false;
    });
  }

  /// Show game over dialog
  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over!'),
          content: Text('You survived for ${AdConstants.gameCountdownSeconds} seconds!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (_isInterstitialAdReady && _interstitialAd != null) {
                  _interstitialAd!.show();
                } else {
                  _restartGame();
                }
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  /// Restart the game
  void _restartGame() {
    _countdownTimer.stop();
    _startGame();
    if (!_isInterstitialAdReady) {
      _loadAd();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interstitial Ads'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_gamePaused ? Icons.play_arrow : Icons.pause),
            onPressed: _gameOver ? null : (_gamePaused ? _resumeGame : _pauseGame),
            tooltip: _gamePaused ? 'Resume Game' : 'Pause Game',
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                          Icons.fullscreen,
                          color: Colors.orange,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Interstitial Ads',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Interstitial ads are full-screen ads that cover the interface of their host app. They\'re typically displayed at natural transition points in the flow of an app.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Game Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      'The Impossible Game',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Timer Display
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primaryContainer,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 4,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _countdownTimer.isComplete 
                                  ? 'DONE!' 
                                  : _countdownTimer.timeLeft.toString(),
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                            if (!_countdownTimer.isComplete)
                              Text(
                                'seconds',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Game Status
                    Text(
                      _gameOver
                          ? 'Game Over!'
                          : _gamePaused
                              ? 'Game Paused'
                              : 'Survive the countdown!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Play Again Button
                    if (_gameOver)
                      ElevatedButton.icon(
                        onPressed: _restartGame,
                        icon: const Icon(Icons.replay),
                        label: const Text('Play Again'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
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
                            color: _isInterstitialAdReady ? Colors.green : Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isInterstitialAdReady ? 'Ad Ready' : 'Loading Ad...',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ad Unit ID: ${AdConstants.interstitialAdUnitId}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
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
                      '• Wait for the countdown to reach zero\n'
                      '• When the game ends, an interstitial ad will show\n'
                      '• After dismissing the ad, you can play again\n'
                      '• The ad loads automatically for the next game',
                      style: Theme.of(context).textTheme.bodyMedium,
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
} 