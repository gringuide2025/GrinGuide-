import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../profile/profile_controller.dart';
import '../dashboard/report_screen.dart';
import '../../shared/utils/image_helper.dart';

class WeeklyReportsScreen extends ConsumerWidget {
  const WeeklyReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(childrenProvider);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        context.go('/dashboard');
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Weekly Reports")),
        body: childrenAsync.when(
          data: (children) {
            if (children.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     const Text("No children profiles found."),
                     const SizedBox(height: 10),
                     ElevatedButton(
                       onPressed: () => context.go('/profile/add-child'), 
                       child: const Text("Add Child")
                     )
                  ],
                ),
              );
            }
  
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: children.length,
              itemBuilder: (context, index) {
                final child = children[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: getProfileImageProvider(child.profilePhotoUrl),
                      child: child.profilePhotoUrl == null ? const Icon(Icons.person) : null,
                    ),
                    title: Text(child.name),
                    subtitle: const Text("Tap to view report"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ReportScreen(child: child))
                      );
                    },
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text("Error: $e")),
        ),
      ),
    );
  }
}
