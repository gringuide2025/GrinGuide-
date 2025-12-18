import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'models/child_model.dart';
import 'profile_controller.dart';

class ChildEditScreen extends ConsumerStatefulWidget {
  final ChildModel? child; // If null, it's ADD mode
  const ChildEditScreen({super.key, this.child});

  @override
  ConsumerState<ChildEditScreen> createState() => _ChildEditScreenState();
}

class _ChildEditScreenState extends ConsumerState<ChildEditScreen> {
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  DateTime? _dob;
  String _gender = 'boy'; // Default gender

  @override
  void initState() {
    super.initState();
    if (widget.child != null) {
      _nameController.text = widget.child!.name;
      _heightController.text = widget.child!.height.toString();
      _weightController.text = widget.child!.weight.toString();
      _dob = widget.child!.dob;
      _gender = widget.child!.gender;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty || _dob == null) return;
    
    final name = _nameController.text.trim();
    final height = double.tryParse(_heightController.text) ?? 0;
    final weight = double.tryParse(_weightController.text) ?? 0;

    if (widget.child == null) {
      // Add
      await ref.read(profileControllerProvider.notifier).addChild(
        name: name,
        dob: _dob!,
        height: height,
        weight: weight,
        gender: _gender,
      );
    } else {
      // Update
      await ref.read(profileControllerProvider.notifier).updateChild(
        id: widget.child!.id,
        parentId: widget.child!.parentId,
        name: name,
        dob: _dob!,
        height: height,
        weight: weight,
        currentPhotoUrl: widget.child!.profilePhotoUrl,
        gender: _gender,
      );
    }
    if (mounted) context.pop();
  }
  
  Future<void> _delete() async {
    if (widget.child == null) return;
    await ref.read(profileControllerProvider.notifier).deleteChild(widget.child!.id);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.child != null;
    final emoji = _gender == 'girl' ? '👧' : '👦';
    
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? "Edit Child" : "Add Child")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Gender-based emoji avatar
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: _gender == 'girl' ? Colors.pink.shade50 : Colors.blue.shade50,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _gender == 'girl' ? Colors.pink : Colors.blue,
                  width: 3,
                ),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 60),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Gender selection
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('👦 Boy'),
                  selected: _gender == 'boy',
                  onSelected: (selected) {
                    if (selected) setState(() => _gender = 'boy');
                  },
                  selectedColor: Colors.blue.shade100,
                ),
                const SizedBox(width: 16),
                ChoiceChip(
                  label: const Text('👧 Girl'),
                  selected: _gender == 'girl',
                  onSelected: (selected) {
                    if (selected) setState(() => _gender = 'girl');
                  },
                  selectedColor: Colors.pink.shade100,
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Child Name", prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(_dob == null ? "Select Date of Birth" : "DOB: ${DateFormat.yMMMd().format(_dob!)}"),
              trailing: const Icon(Icons.calendar_today),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.grey)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _dob ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null) setState(() => _dob = date);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Height (cm)", suffixText: "cm"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Weight (kg)", suffixText: "kg"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _save,
              child: Text(isEditing ? "Update Child" : "Add Child"),
            ),
             if (isEditing) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: _delete,
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text("Delete Child"),
              )
            ]
          ],
        ),
      ),
    );
  }
}
