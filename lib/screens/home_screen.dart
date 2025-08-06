import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../managers/consent_manager.dart';
import '../utils/app_lifecycle_reactor.dart';
import 'banner_ad_screen.dart';
import 'interstitial_ad_screen.dart';
import 'native_ad_screen.dart';
import 'rewarded_ad_screen.dart';
import 'rewarded_interstitial_ad_screen.dart';

/// Main home screen with navigation to all ad format examples
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isPrivacyOptionsRequired = false;

  @override
  void initState() {
    super.initState();
    _checkPrivacyOptionsRequired();
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
        title: const Text('Ads Pro - AdMob Demo'),
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
                      Icons.ads_click,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Complete AdMob Integration',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Explore all AdMob ad formats with this comprehensive demo app',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Ad Format Cards
            Text(
              'Ad Formats',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // App Open Ad (automatically shown)
            _buildAdFormatCard(
              context: context,
              title: 'App Open Ads',
              description: 'Automatically shown when app comes to foreground',
              icon: Icons.open_in_new,
              color: Colors.green,
              isAutomatic: true,
              onTap: null,
            ),
            
            // Banner Ads
            _buildAdFormatCard(
              context: context,
              title: 'Banner Ads',
              description: 'Rectangular ads that stay on screen',
              icon: Icons.view_stream,
              color: Colors.blue,
              onTap: () => _navigateToScreen(context, const BannerAdScreen()),
            ),
            
            // Interstitial Ads
            _buildAdFormatCard(
              context: context,
              title: 'Interstitial Ads',
              description: 'Full-screen ads shown at natural breaks',
              icon: Icons.fullscreen,
              color: Colors.orange,
              onTap: () => _navigateToScreen(context, const InterstitialAdScreen()),
            ),
            
            // Native Ads
            _buildAdFormatCard(
              context: context,
              title: 'Native Ads',
              description: 'Ads that match your app\'s design',
              icon: Icons.integration_instructions,
              color: Colors.purple,
              onTap: () => _navigateToScreen(context, const NativeAdScreen()),
            ),
            
            // Rewarded Ads
            _buildAdFormatCard(
              context: context,
              title: 'Rewarded Ads',
              description: 'Users get rewards for watching video ads',
              icon: Icons.card_giftcard,
              color: Colors.red,
              onTap: () => _navigateToScreen(context, const RewardedAdScreen()),
            ),
            
            // Rewarded Interstitial Ads
            _buildAdFormatCard(
              context: context,
              title: 'Rewarded Interstitial',
              description: 'Full-screen rewarded video ads',
              icon: Icons.video_collection,
              color: Colors.teal,
              onTap: () => _navigateToScreen(context, const RewardedInterstitialAdScreen()),
            ),
            
            const SizedBox(height: 32),
            
            // Debug Information (only in debug mode)
            if (kDebugMode) ...[
              Text(
                'Debug Information',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildDebugCard(),
            ],
          ],
        ),
      ),
    );
  }

  /// Build app bar actions
  List<Widget> _buildAppBarActions() {
    final actions = <Widget>[
      // Ad Inspector
      PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        onSelected: (value) {
          switch (value) {
            case 'ad_inspector':
              _openAdInspector();
              break;
            case 'privacy_options':
              _showPrivacyOptions();
              break;
          }
        },
        itemBuilder: (context) {
          final items = <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'ad_inspector',
              child: ListTile(
                leading: Icon(Icons.bug_report),
                title: Text('Ad Inspector'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ];
          
          if (_isPrivacyOptionsRequired) {
            items.add(
              const PopupMenuItem<String>(
                value: 'privacy_options',
                child: ListTile(
                  leading: Icon(Icons.privacy_tip),
                  title: Text('Privacy Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            );
          }
          
          return items;
        },
      ),
    ];
    
    return actions;
  }

  /// Build ad format card
  Widget _buildAdFormatCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
    bool isAutomatic = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isAutomatic)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'AUTO',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build debug information card
  Widget _buildDebugCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bug_report,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Debug Mode Active',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FutureBuilder<String>(
              future: MobileAds.instance.getVersionString(),
              builder: (context, snapshot) {
                return Text(
                  'Mobile Ads SDK: ${snapshot.data ?? 'Loading...'}',
                  style: Theme.of(context).textTheme.bodySmall,
                );
              },
            ),
            const SizedBox(height: 8),
            FutureBuilder<Map<String, dynamic>>(
              future: ConsentManager.instance.getConsentDebugInfo(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final info = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Consent Status: ${info['canRequestAds'] ? 'Can Request Ads' : 'Cannot Request Ads'}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        'GDPR Applicable: ${info['isGDPRApplicable']}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  );
                }
                return Text(
                  'Loading consent info...',
                  style: Theme.of(context).textTheme.bodySmall,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Navigate to a screen
  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  /// Open Ad Inspector
  void _openAdInspector() {
    MobileAds.instance.openAdInspector((error) {
      if (error != null && kDebugMode) {
        print('HomeScreen: Ad Inspector error: $error');
      }
    });
  }

  /// Show privacy options form
  void _showPrivacyOptions() {
    ConsentManager.instance.showPrivacyOptionsForm((formError) {
      if (formError != null && kDebugMode) {
        print('HomeScreen: Privacy options error: $formError');
      }
    });
  }
} 