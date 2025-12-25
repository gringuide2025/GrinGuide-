import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

final settingsControllerProvider = StateNotifierProvider<SettingsController, SettingsState>((ref) {
  return SettingsController();
});

  final bool notificationsEnabled;
  // Sound preference removed - using system default

  SettingsState({
    required this.themeMode,
    required this.locale,
    required this.notificationsEnabled,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? notificationsEnabled,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

  SettingsController() : super(SettingsState(
    themeMode: ThemeMode.system, 
    locale: const Locale('en'), 
    notificationsEnabled: true,
  )) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('themeMode') ?? 0;
    final langCode = prefs.getString('languageCode') ?? 'en';
    final notif = prefs.getBool('notificationsEnabled') ?? true;
    state = SettingsState(
      themeMode: ThemeMode.values[themeIndex],
      locale: Locale(langCode),
      notificationsEnabled: notif,
    );
  }

  Future<void> toggleTheme(bool isDark) async {
    final mode = isDark ? ThemeMode.dark : ThemeMode.light;
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }

  Future<void> setLocale(String languageCode) async {
    state = state.copyWith(locale: Locale(languageCode));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', languageCode);
  }

  Future<void> toggleNotifications(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', enabled);
    
    // Disable/Enable Push
    if (enabled) {
      OneSignal.User.pushSubscription.optIn();
    } else {
      OneSignal.User.pushSubscription.optOut();
    }
  }

    // Sound preference removed - using system default
  }

  Future<void> deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.delete();
      // Auth state change will trigger in main, but UI handles navigation too.
    }
  }
}
