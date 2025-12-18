import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'settings_controller.dart';

import 'package:audioplayers/audioplayers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    
    final isDark = settings.themeMode == ThemeMode.dark;

    // Helper to show selection sheet
    void showSoundSelection() {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))
        ),
        builder: (ctx) {
          return Consumer(
            builder: (context, ref, _) {
              // We watch again to update checkmark
              final currentSoundId = ref.watch(settingsControllerProvider).selectedSound;
              
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Choose Notification Sound",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ...SettingsController.sounds.map((sound) {
                      final isSelected = currentSoundId == sound['id'];
                      return ListTile(
                        leading: Text(sound['emoji']!, style: const TextStyle(fontSize: 24)),
                        title: Text(sound['name']!),
                        trailing: isSelected 
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                        onTap: () async {
                          // 1. Set Sound
                          controller.setNotificationSound(sound['id']!);
                          
                          // 2. Play Preview
                          // We use the assets copies for preview
                          final player = AudioPlayer();
                          // AudioPlayer expects path relative to assets/ for AssetSource? 
                          // No, AssetSource('audio/sound.mp3')
                          await player.play(AssetSource('audio/${sound['id']}.mp3'));
                          
                          // Close? No, let them keep it open to hear others.
                          // But we need to refresh the UI (Consumer handles it).
                        },
                      );
                    }).toList(), 
                    const SizedBox(height: 20),
                  ],
                ),
              );
            }
          );
        }
      );
    }

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
            ListTile(
              title: const Text("Notification Sound"),
              subtitle: Text(
                SettingsController.sounds.firstWhere(
                  (s) => s['id'] == settings.selectedSound,
                  orElse: () => {'name': 'Default'}
                )['name']!
              ),
              leading: const Icon(Icons.music_note),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: showSoundSelection,
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
              child: Text("Version 1.0.0", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}
