import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'settings_controller.dart';



class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        context.go('/dashboard');
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Settings")),
        body: ListView(
          children: [
            SwitchListTile(
              title: const Text("Dark Mode"),
              secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
              value: isDark,
              onChanged: (val) => controller.toggleTheme(val),
            ),
            SwitchListTile(
              title: const Text("Promotional Notifications"),
              secondary: const Icon(Icons.notifications),
              value: settings.notificationsEnabled,
              onChanged: (val) => controller.toggleNotifications(val),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text("Help & Support"),
              onTap: () => context.go('/settings/support'),
            ),
            ListTile(
              leading: const Icon(Icons.mail),
              title: const Text("Contact Us"),
              onTap: () => context.go('/settings/support'),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text("Terms & Conditions"),
              onTap: () => context.go('/settings/terms'),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text("Privacy Policy"),
              onTap: () => context.go('/settings/privacy'),
            ),
            const Divider(),
             ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text("Delete Account", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context, 
                  builder: (ctx) => AlertDialog(
                    title: const Text("Delete Account?"),
                    content: const Text("This action cannot be undone. All your data including child profiles and vaccination records will be permanently deleted."),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                        onPressed: () => Navigator.pop(ctx, true), 
                        child: const Text("Delete")
                      ),
                    ],
                  )
                );

                if (confirm == true && context.mounted) {
                   try {
                     // 1. Delete from Firebase
                     // Ideally we should delete Firestore data first using a Cloud Function or here manually
                     // For MVP compliance, deleting Auth user is the primary step.
                     await controller.deleteAccount();
                     
                     if (context.mounted) {
                       context.go('/login');
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Account deleted successfully.")));
                     }
                   } catch (e) {
                     if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: Re-login required to delete account. $e")));
                     }
                   }
                }
              },
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Version 1.0.4+7", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}
