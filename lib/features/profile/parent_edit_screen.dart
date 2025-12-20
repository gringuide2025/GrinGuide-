import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_controller.dart';

class ParentEditScreen extends ConsumerStatefulWidget {
  const ParentEditScreen({super.key});

  @override
  ConsumerState<ParentEditScreen> createState() => _ParentEditScreenState();
}

class _ParentEditScreenState extends ConsumerState<ParentEditScreen> {
  final _fatherNameController = TextEditingController();
  final _motherNameController = TextEditingController();


  @override
  void initState() {
    super.initState();
    // Pre-fill if data exists
    final parent = ref.read(parentProfileProvider).value;
    if (parent != null) {
      _fatherNameController.text = parent.fatherName;
      _motherNameController.text = parent.motherName;
    }
  }

  @override
  void dispose() {
    _fatherNameController.dispose();
    _motherNameController.dispose();
    super.dispose();
  }

  void _save() async {
      await ref.read(profileControllerProvider.notifier).saveParentProfile(
        _fatherNameController.text.trim(),
        _motherNameController.text.trim(),
        FirebaseAuth.instance.currentUser?.email ?? '',
        '',
      );
      ref.invalidate(parentProfileProvider);
      if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Parent Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
               TextFormField(
                controller: _fatherNameController,
                decoration: const InputDecoration(
                  labelText: "Father's Name",
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _motherNameController,
                decoration: const InputDecoration(
                  labelText: "Mother's Name",
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _save,
                child: const Text("Save Changes"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
