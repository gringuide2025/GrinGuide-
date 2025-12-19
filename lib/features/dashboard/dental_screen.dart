import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/services/notification_service.dart';
import '../profile/models/child_model.dart';
import 'models/dental_appointment_model.dart';
import 'eruption_chart_screen.dart';

// Repository
final dentalRepositoryProvider = Provider((ref) => DentalRepository(FirebaseFirestore.instance));

class DentalRepository {
  final FirebaseFirestore _firestore;
  DentalRepository(this._firestore);

  Stream<List<DentalAppointmentModel>> getAppointments(String childId) {
    return _firestore.collection('dental_appointments')
        .where('childId', isEqualTo: childId)
        .snapshots()
        .map((snap) {
          final list = snap.docs.map((d) => DentalAppointmentModel.fromMap(d.data())).toList();
          list.sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
          return list;
        });
  }

  Future<void> addAppointment(DentalAppointmentModel appt) async {
    await _firestore.collection('dental_appointments').doc(appt.id).set(appt.toMap(), SetOptions(merge: true));
    
    // Notification is handled by Backend (OneSignal)
    // No local schedule.
  }

  Future<void> deleteAppointment(String id) async {
    await _firestore.collection('dental_appointments').doc(id).delete();
  }


  Future<void> ensureNextDefaultAppointment(ChildModel child) async {
    // Calculate the next default appointment based on DOB
    final dob = child.dob;
    final now = DateTime.now();
    
    // Find which 6-month interval we're in
    final monthsSinceBirth = (now.year - dob.year) * 12 + (now.month - dob.month);
    
    // Calculate next appointment (every 6 months starting from 6 months after birth)
    // If child is 0-5 months old, next appointment is at 6 months
    // If child is 6-11 months old, next appointment is at 12 months, etc.
    int nextIntervalNumber = ((monthsSinceBirth / 6).floor() + 1);
    if (monthsSinceBirth < 6) nextIntervalNumber = 1; // First appointment at 6 months
    
    final nextMonths = nextIntervalNumber * 6;
    var nextDate = DateTime(dob.year, dob.month + nextMonths, dob.day);
    
    // Adjust if Sunday
    if (nextDate.weekday == DateTime.sunday) {
      nextDate = nextDate.add(const Duration(days: 1));
    }
    
    // Check if this default appointment already exists
    final defaultId = '${child.id}_default_checkup';
    final existingSnap = await _firestore.collection('dental_appointments').doc(defaultId).get();
    
    if (existingSnap.exists) {
      final existing = DentalAppointmentModel.fromMap(existingSnap.data()!);
      
      // If existing is done or in the past, create the next one
      if (existing.isDone || existing.appointmentDate.isBefore(DateTime(now.year, now.month, now.day))) {
        // Delete old default and create new one
        await _firestore.collection('dental_appointments').doc(defaultId).delete();
        
        final newAppt = DentalAppointmentModel(
          id: defaultId,
          childId: child.id,
          doctorName: "Pediatric Dentist",
          appointmentDate: nextDate,
          notes: "Routine 6-month Checkup (Age ${nextMonths/12} years)",
          purpose: "Routine Checkup (Default)",
          isDone: false,
          parentId: child.parentId,
        );
        await _firestore.collection('dental_appointments').doc(defaultId).set(newAppt.toMap());
      }
      // If existing is still upcoming, keep it
    } else {
      // Create first default appointment
      final appt = DentalAppointmentModel(
        id: defaultId,
        childId: child.id,
        doctorName: "Pediatric Dentist",
        appointmentDate: nextDate,
        notes: "Routine 6-month Checkup (Age ${nextMonths/12} years)",
        purpose: "Routine Checkup (Default)",
        isDone: false,
        parentId: child.parentId,
      );
      await _firestore.collection('dental_appointments').doc(defaultId).set(appt.toMap());
    }
  }

  Future<void> markAsDone(String id) async {
    await _firestore.collection('dental_appointments').doc(id).update({'isDone': true});
  }
}

// UI
class DentalScreen extends StatelessWidget {
  final ChildModel child;
  const DentalScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dental - ${child.name}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_on_rounded),
            tooltip: 'Eruption Chart',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EruptionChartScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddAppointmentDialog(context, null), 
            // Better to keep showDialog in the Widget context.
            // Actually, we can just call the static method or duplicate logic? 
            // Simpler: DentalBody can handle the add dialog if we move button there?
            // User requirement: "Tabs". The "Add" button typically goes in FAB or AppBar.
            // If in AppBar (Dashboard AppBar), we need to bubble up action?
            // Or DentalBody has a FAB?
            // Let's keep DentalScreen logic simple for now, and DentalBody just displays.
            // But DentalBody needs the "Add" functionality if it's the main view.
            // I'll make DentalBody have a FAB.
          )
        ],
      ),
      body: DentalBody(child: child),
    );
  }

  void _showAddAppointmentDialog(BuildContext context, WidgetRef? ref) {
    // Moved logic to DentalBody or KEEP IT here? 
    // If I use DentalBody in Dashboard, I need layout.
    // I'll put the Add logic in DentalBody and use a FAB.
  }
}

class DentalBody extends ConsumerStatefulWidget {
  final ChildModel child;
  const DentalBody({super.key, required this.child});

  @override
  ConsumerState<DentalBody> createState() => _DentalBodyState();
}

class _DentalBodyState extends ConsumerState<DentalBody> {
  @override
  Widget build(BuildContext context) {
    final appointmentsAsync = ref.watch(dentalAppointmentsProvider(widget.child.id));

    // Ensure next default appointment exists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dentalRepositoryProvider).ensureNextDefaultAppointment(widget.child);
    });

    return Scaffold( // Internal scaffold for FAB? Or just Column with FAB overlay?
      // If we nest Scaffold, we get FAB support easily.
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAppointmentDialog(context),
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Standard Info Card
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("🦷", style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text("Standard Reminders", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onPrimaryContainer)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text("• Dental Checkup every 6 months", style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer)),
                    Text("• First checkup by age 1 or after first tooth erupts", style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer)),
                    const SizedBox(height: 5),
                    Text("Note: Everyone has a different eruption timing and eruption pattern, any queries visit the dentist", style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontSize: 13, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            appointmentsAsync.when(
              data: (list) {
                 final now = DateTime.now();
                 final today = DateTime(now.year, now.month, now.day); // Strip time
                 
                 final future = list.where((a) => a.appointmentDate.isAfter(today) || a.appointmentDate.isAtSameMomentAs(today)).toList();
                 final past = list.where((a) => a.appointmentDate.isBefore(today)).toList();

                 // Sort
                 future.sort((a,b) => a.appointmentDate.compareTo(b.appointmentDate));
                 past.sort((a,b) => b.appointmentDate.compareTo(a.appointmentDate)); // Newest past first

                 return Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     // UPCOMING
                     Row(
                       children: [                         const Icon(Icons.calendar_month, color: Colors.blue),
                         const SizedBox(width: 8),
                         Text("Upcoming Appointments", style: Theme.of(context).textTheme.titleLarge),
                       ],
                     ),
                     const SizedBox(height: 10),
                     if(future.isEmpty)
                       const Padding(padding: EdgeInsets.only(left: 32, bottom: 20), child: Text("No upcoming appointments.")),
                     
                     ...future.map((appt) => _buildAppointmentCard(context, appt, isPast: false)),
                     
                     const Divider(height: 40),

                     // PAST
                     Row(
                       children: [                         const Icon(Icons.history, color: Colors.grey),
                         const SizedBox(width: 8),
                         Text("Past Appointments", style: Theme.of(context).textTheme.titleLarge),
                       ],
                     ),
                     const SizedBox(height: 10),
                     if(past.isEmpty)
                       const Padding(padding: EdgeInsets.only(left: 32), child: Text("No past appointments.")),

                     ...past.map((appt) => _buildAppointmentCard(context, appt, isPast: true)),
                   ],
                 );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e,_) => Text("Error: $e"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(BuildContext context, DentalAppointmentModel appt, {required bool isPast}) {
    return Card(
      elevation: isPast ? 1 : 4,
      color: isPast ? Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5) : null,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(Icons.event_note, color: isPast ? Colors.grey : Colors.blue),
        title: Text(appt.purpose, style: TextStyle(decoration: isPast ? TextDecoration.lineThrough : null)),
        subtitle: Text("${appt.doctorName} • ${DateFormat.yMMMd().format(appt.appointmentDate)}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showAddAppointmentDialog(context, appt),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteAppt(appt.id),
            ),
          ],
        ),
        onTap: () => _showAddAppointmentDialog(context, appt), // Edit on tap
      ),
    );
  }

  Future<void> _deleteAppt(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete?"),
        actions: [
          TextButton(onPressed: ()=>Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: ()=>Navigator.pop(ctx, true), child: const Text("Delete")),
        ],
      )
    );
    if(confirm == true) {
      ref.read(dentalRepositoryProvider).deleteAppointment(id);
    }
  }

  void _showAddAppointmentDialog(BuildContext context, [DentalAppointmentModel? existing]) {
    final doctorController = TextEditingController(text: existing?.doctorName);
    final purposeController = TextEditingController(text: existing?.purpose);
    DateTime selectedDate = existing?.appointmentDate ?? DateTime.now().add(const Duration(days: 1));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(existing == null ? "Add Appointment" : "Edit Appointment"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: doctorController, decoration: const InputDecoration(labelText: "Doctor Name")),
                TextField(controller: purposeController, decoration: const InputDecoration(labelText: "Purpose")),
                const SizedBox(height: 10),
                ListTile(
                  title: Text(DateFormat.yMMMd().format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context, 
                      initialDate: selectedDate, 
                      firstDate: DateTime.now().subtract(const Duration(days: 365)), // Allow past for corrections
                      lastDate: DateTime.now().add(const Duration(days: 365*5))
                    );
                    if(d!=null) setDialogState(() => selectedDate = d);
                  },
                )
              ],
            ),
            actions: [
              TextButton(onPressed: () => context.pop(), child: const Text("Cancel")),
              ElevatedButton(
                onPressed: () {
                   final appt = DentalAppointmentModel(
                     id: existing?.id ?? const Uuid().v4(),
                     childId: widget.child.id,
                     doctorName: doctorController.text,
                     purpose: purposeController.text,
                     appointmentDate: selectedDate,
                     isDone: existing?.isDone ?? false,
                     notes: existing?.notes,
                     parentId: widget.child.parentId,
                   );
                   // Create/Update use the same set() with merge usually, but repository has standard add.
                   // Let's use addAppointment which does set().
                   ref.read(dentalRepositoryProvider).addAppointment(appt);
                   context.pop();
                },
                child: const Text("Save"),
              )
            ],
          );
        }
      ),
    );
  }
}

final dentalAppointmentsProvider = StreamProvider.family((ref, String childId) {
  return ref.watch(dentalRepositoryProvider).getAppointments(childId);
});
