import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'managers/consent_manager.dart';
import 'utils/app_lifecycle_reactor.dart';
import 'screens/home_screen.dart';
import 'core/ad_constants.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    print('AdsPro: Starting application initialization');
  }

  // Initialize the Mobile Ads SDK
  await _initializeMobileAds();

  // Initialize consent management
  await _initializeConsent();

  // Initialize app lifecycle reactor for app open ads
  _initializeAppLifecycle();

  // Run the app
  runApp(const AdsProApp());
}

/// Initialize the Mobile Ads SDK
Future<void> _initializeMobileAds() async {
  try {
    if (kDebugMode) {
      print('AdsPro: Initializing Mobile Ads SDK...');
    }

    final initializationStatus = await MobileAds.instance.initialize();
    
    if (kDebugMode) {
      print('AdsPro: Mobile Ads SDK initialized successfully');
      
      // Print adapter initialization status
      initializationStatus.adapterStatuses.forEach((key, value) {
        print('AdsPro: Adapter $key: ${value.description}');
      });
    }

    // Configure request configuration for debugging
    if (AdConstants.enableAdDebugLogging) {
      final requestConfiguration = RequestConfiguration(
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.unspecified,
        tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.unspecified,
        testDeviceIds: AdConstants.testDeviceIds,
      );
      
      MobileAds.instance.updateRequestConfiguration(requestConfiguration);
      
      if (kDebugMode) {
        print('AdsPro: Request configuration updated with test devices');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('AdsPro: Error initializing Mobile Ads SDK: $e');
    }
  }
}

/// Initialize consent management
Future<void> _initializeConsent() async {
  try {
    if (kDebugMode) {
      print('AdsPro: Initializing consent management...');
    }

    await ConsentManager.instance.initializeConsent(
      forceEEA: false, // Set to true for testing GDPR flow
      maxRetries: 3,
    );

    if (kDebugMode) {
      final debugInfo = await ConsentManager.instance.getConsentDebugInfo();
      print('AdsPro: Consent debug info: $debugInfo');
    }
  } catch (e) {
    if (kDebugMode) {
      print('AdsPro: Error initializing consent: $e');
    }
  }
}

/// Initialize app lifecycle reactor for app open ads
void _initializeAppLifecycle() {
  try {
    if (kDebugMode) {
      print('AdsPro: Initializing app lifecycle reactor...');
    }

    AppLifecycleReactor().initialize();

    if (kDebugMode) {
      print('AdsPro: App lifecycle reactor initialized successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('AdsPro: Error initializing app lifecycle reactor: $e');
    }
  }
}

/// The main application widget
class AdsProApp extends StatelessWidget {
  const AdsProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ads Pro - Complete AdMob Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
} 