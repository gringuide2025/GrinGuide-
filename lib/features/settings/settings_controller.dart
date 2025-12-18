import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

final settingsControllerProvider = StateNotifierProvider<SettingsController, SettingsState>((ref) {
  return SettingsController();
});

class SettingsState {
  final ThemeMode themeMode;
  final Locale locale;
  final bool notificationsEnabled;
  final String selectedSound;

  SettingsState({
    required this.themeMode,
    required this.locale,
    required this.notificationsEnabled,
    required this.selectedSound,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? notificationsEnabled,
    String? selectedSound,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      selectedSound: selectedSound ?? this.selectedSound,
    );
  }
}

class SettingsController extends StateNotifier<SettingsState> {
  // Available sounds - Exposed for UI
  static const List<Map<String, String>> sounds = [
    {'id': 'sound_chime', 'name': 'Soft Chime', 'emoji': '🔔'},
    {'id': 'sound_magic', 'name': 'Magic Wand', 'emoji': '✨'},
    {'id': 'sound_pop', 'name': 'Pop!', 'emoji': '🎈'},
    {'id': 'sound_bird', 'name': 'Bird Chirp', 'emoji': '🐦'},
    {'id': 'sound_power', 'name': 'Super Power', 'emoji': '🚀'},
  ];

  SettingsController() : super(SettingsState(
    themeMode: ThemeMode.system, 
    locale: const Locale('en'), 
    notificationsEnabled: true,
    selectedSound: 'sound_chime',
  )) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('themeMode') ?? 0;
    final langCode = prefs.getString('languageCode') ?? 'en';
    final notif = prefs.getBool('notificationsEnabled') ?? true;
    final sound = prefs.getString('notificationSound') ?? 'sound_chime';

    state = SettingsState(
      themeMode: ThemeMode.values[themeIndex],
      locale: Locale(langCode),
      notificationsEnabled: notif,
      selectedSound: sound,
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

  Future<void> setNotificationSound(String soundId) async {
    // 1. Update State
    state = state.copyWith(selectedSound: soundId);
    
    // 2. Persist
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notificationSound', soundId);
    
    // 3. Tag User in OneSignal
    OneSignal.User.addTags({"notification_sound": soundId});
  }

  Future<void> deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.delete();
      // Auth state change will trigger in main, but UI handles navigation too.
    }
  }
}
