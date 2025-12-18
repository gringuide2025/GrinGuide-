import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/child_model.dart';
import 'profile_controller.dart';
import '../../shared/utils/image_helper.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {

  @override
  Widget build(BuildContext context) {
    final parentAsync = ref.watch(parentProfileProvider);
    final childrenAsync = ref.watch(childrenProvider);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        context.go('/dashboard');
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Parent Profile Section
            _buildSectionHeader(context, "Parent Profile", () {
               context.go('/profile/edit-parent');
            }),
            const SizedBox(height: 10),
            parentAsync.when(
              data: (parent) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            child: Icon(Icons.person, size: 30),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  parent?.fatherName ?? "Father's Name",
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(
                                  "Mother: ${parent?.motherName ?? "Mother's Name"}",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => context.go('/profile/edit-parent'),
                          ),
                        ],
                      ),
  
                    ],
                  ),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error: $err'),
            ),
  
            const SizedBox(height: 24),
  
            // Children Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Children Details", style: Theme.of(context).textTheme.titleLarge),
                childrenAsync.when(
                  data: (children) {
                     if (children.length < 3) {
                       return IconButton(
                          onPressed: () => context.go('/profile/add-child'),
                          icon: const Icon(Icons.add_circle, color: Colors.green, size: 30),
                          tooltip: "Add Child",
                        );
                     }
                     return const SizedBox.shrink();
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_,__) => const SizedBox.shrink(),
                )
              ],
            ),
            const SizedBox(height: 10),
            childrenAsync.when(
              data: (children) {
                if (children.isEmpty) {
                  return const Center(child: Text("No children added. Add up to 3 children."));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: children.length,
                  itemBuilder: (context, index) {
                    final child = children[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: child.gender == 'girl' ? Colors.pink.shade50 : Colors.blue.shade50,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: child.gender == 'girl' ? Colors.pink : Colors.blue,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              child.defaultEmoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        title: Text(child.name),
                        subtitle: Text("${DateFormat.yMMMd().format(child.dob)} • BMI: ${child.bmi.toStringAsFixed(1)}"),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => context.go('/profile/edit-child', extra: child),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error: $err'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback onEdit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}
