import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'core/theme/app_theme.dart';
import 'package:grin_guide/router/app_router.dart';
import 'features/settings/settings_controller.dart';
import 'firebase_options.dart';
import 'shared/services/notification_service.dart';
import 'core/localization/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialized check
  bool initialized = false;

  try {
    // Initialize Firebase
    debugPrint("Initializing Firebase...");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 15), onTimeout: () {
      debugPrint("Firebase init timed out"); 
      throw Exception('Firebase initialization timed out');
    });
    debugPrint("Firebase Initialized");


    // Initialize OneSignal
    try {
      debugPrint("Initializing OneSignal...");
      OneSignal.Debug.setLogLevel(OSLogLevel.none);
      OneSignal.initialize("48d29f47-c4fa-4e66-86fc-304ffbeff598");
      
      debugPrint("OneSignal SDK Initialized");
      
      // CRITICAL: Wait for OneSignal to fully initialize before requesting permission
      // This is required for Android 13+ to properly register the device
      await Future.delayed(const Duration(seconds: 2));
      debugPrint("Waiting for OneSignal to fully initialize...");
      
      // Request notification permission and wait for response
      final permissionGranted = await OneSignal.Notifications.requestPermission(true);
      debugPrint("Notification permission granted: $permissionGranted");
      
      if (!permissionGranted) {
        debugPrint("⚠️ WARNING: Notification permission denied. Push notifications will not work.");
      } else {
        debugPrint("✅ Notification permission granted successfully");
        // Give OneSignal time to register the device after permission is granted
        await Future.delayed(const Duration(seconds: 1));
      }
      
      debugPrint("✅ OneSignal Initialized Successfully");
      
      // Check if user is already logged in and link with OneSignal
      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          debugPrint("User already logged in: ${currentUser.uid}");
          OneSignal.login(currentUser.uid);
          debugPrint("OneSignal login called for existing user");
        }
      } catch (e) {
        debugPrint("Error checking existing user: $e");
      }
      
    } catch (e) {
      debugPrint("❌ OneSignal Initialization Failed: $e");
    }



    // Local Notifications
    debugPrint("Initializing Local Notifications...");
    final notifService = NotificationService();
    try {
      await notifService.init();
      // notifService.requestPermissions(); // Request permissions (async)
       debugPrint("Local Notifications Initialized");
      

      
    } catch (e) {
       debugPrint("Local Notifications Init Failed/Timed out: $e");
    }
    
    initialized = true;
  } catch (e, stack) {
    debugPrint("Initialization Error: $e\n$stack");
  }

  debugPrint("Calling runApp (initialized: $initialized)");
  runApp(const ProviderScope(child: GrinGuideApp()));
}





class GrinGuideApp extends ConsumerWidget {
  const GrinGuideApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);

    return MaterialApp.router(
      title: 'GrinGuide',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      locale: settings.locale,
      // Localization Support
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('ta', ''),
      ],
      // Locale is updated via ref.watch of a locale provider if we had one, 
      // but for now we rely on system or internal state. 
      // To strictly force it from settings, we'd need to wrap MaterialApp in a Consumer 
      // that watches the LocaleController.
      // Since SettingsController saves to Prefs, we might need a restart or a better listener here.
      // For this MVP, let's assume usage of system or a simpler rebuild trigger if we want dynamic switching.
      
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
