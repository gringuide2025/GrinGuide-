import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateService {
  static const String _lastVersionKey = 'last_seen_version';

  static Future<void> checkUpdate(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final packageInfo = await PackageInfo.fromPlatform();
    
    final currentVersion = packageInfo.version;
    final lastVersion = prefs.getString(_lastVersionKey);

    if (lastVersion == null) {
      // First install: Save version, maybe let Tour handle onboarding
      await prefs.setString(_lastVersionKey, currentVersion);
      return;
    }

    if (currentVersion != lastVersion) {
      // Update detected! Show dialog.
      if (context.mounted) {
        await _showUpdateDialog(context, currentVersion);
        await prefs.setString(_lastVersionKey, currentVersion);
      }
    }
  }

  static Future<void> _showUpdateDialog(BuildContext context, String version) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("What's New in v$version 🎉"),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("• 📅 Date Input: Easier date entry with auto-formatting!"),
              SizedBox(height: 8),
              Text("• 📖 Stories: Improved subtitle visibility (now below image)."),
              SizedBox(height: 8),
              Text("• 🦠 Vaccines: You can now verify vaccines manually."),
              SizedBox(height: 8),
              Text("• 🦷 Dental: Fixed appointment scheduling bugs."),
              SizedBox(height: 8),
              Text("• 🐛 Performance improvements and bug fixes."),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Awesome!"),
          ),
        ],
      ),
    );
  }
}
