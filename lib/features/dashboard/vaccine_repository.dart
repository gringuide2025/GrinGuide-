import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/services/notification_service.dart';
import '../profile/models/child_model.dart';
import 'models/vaccine_model.dart';

final vaccineRepositoryProvider = Provider((ref) => VaccineRepository(FirebaseFirestore.instance));

class VaccineRepository {
  final FirebaseFirestore _firestore;

  VaccineRepository(this._firestore);

  Stream<List<VaccineModel>> getVaccines(String childId, String parentId) {
     return _firestore.collection('vaccines')
         .where('childId', isEqualTo: childId)
         .where('parentId', isEqualTo: parentId)
         .snapshots()
         .map((snapshot) {
           final list = snapshot.docs.map((doc) => VaccineModel.fromMap(doc.data())).toList();
           list.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
           return list;
         });
  }
  
  Future<void> initializeVaccinesForChild(ChildModel child) async {
    debugPrint("💉 initializeVaccinesForChild called for: ${child.name} (${child.id})");
    // Check if exists
    final snap = await _firestore.collection('vaccines')
        .where('childId', isEqualTo: child.id)
        .where('parentId', isEqualTo: child.parentId)
        .limit(1).get();
    if (snap.docs.isNotEmpty) {
       debugPrint("💉 Vaccines already exist for child. Count: ${snap.docs.length}");
       return;
    }

    debugPrint("💉 Generating NIS Schedule...");
    // Generate WHO Schedule based on DOB
    final List<VaccineModel> vaccines = _generateWHOSchedule(child);
    debugPrint("💉 Generated ${vaccines.length} vaccines. Starting batch commit...");
    
    try {
      final batch = _firestore.batch();
      for (var v in vaccines) {
        final docRef = _firestore.collection('vaccines').doc(v.id);
        batch.set(docRef, v.toMap());
      }
      await batch.commit();
      debugPrint("💉 Batch commit successful!");
    } catch (e) {
      debugPrint("❌ Error initializing vaccines: $e");
    }
  }
  
  Future<void> updateVaccineStatus(String vaccineId, bool isDone, DateTime? actualDate, {String? doctorName}) async {
    final data = {
      'isDone': isDone,
      'actualDate': actualDate?.toIso8601String(),
    };
    if (doctorName != null) {
      data['doctorName'] = doctorName;
    } else if (!isDone) {
      // If marking as not done, clear doctor name? 
      // Firestore update doesn't support deleting field easily without FieldValue.delete(), 
      // but setting to null or empty string is fine for now usually.
      // But map values usually can't be null in some setups. 
      // Let's use FieldValue.delete() if not done.
       data['doctorName'] = FieldValue.delete();
    }
    
    // Actually, 'data' values: Map<String, Object?>. 
    await _firestore.collection('vaccines').doc(vaccineId).update(data);
  }

  Future<void> updateVaccineDoctor(String vaccineId, String doctorName) async {
    await _firestore.collection('vaccines').doc(vaccineId).update({
      'doctorName': doctorName,
    });
  }

  Future<void> updateVaccineDate(String vaccineId, DateTime newDate) async {
    await _firestore.collection('vaccines').doc(vaccineId).update({
      'scheduledDate': newDate.toIso8601String(),
    });
    
    // Notification is handled by Backend (OneSignal)
    // No local schedule.
  }

  List<VaccineModel> _generateWHOSchedule(ChildModel child) {
    final dob = child.dob;
    final idPrefix = child.id;
    
    // Helper to create vaccine
    VaccineModel create(String name, Duration age) {
      if (age == Duration.zero) {
        // At birth, just use date of birth
        final safeName = name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
        return VaccineModel(
          id: '${idPrefix}_$safeName',
          vaccineName: name, 
          scheduledDate: dob, 
          childId: child.id,
          parentId: child.parentId,
        );
      }
      
      var date = dob.add(age);
      if (date.weekday == DateTime.sunday) {
        date = date.add(const Duration(days: 1)); // Move Sunday to Monday
      }
      // Sanitize ID: Remove spaces, slashes, and special chars
      final safeName = name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
      
      return VaccineModel(
        id: '${idPrefix}_$safeName',
        vaccineName: name, 
        scheduledDate: date, 
        childId: child.id,
        parentId: child.parentId,
      );
    }
    
    // Durations based on NIS Chart
    const weeks6 = Duration(days: 42);
    const weeks10 = Duration(days: 70);
    const weeks14 = Duration(days: 98);
    
    // 9-12 months -> Taking earliest 9 months (270 days)
    const months9 = Duration(days: 270); 
    
    // 16-24 months -> Taking 16 months (480 days)
    const months16 = Duration(days: 480);
    
    // 5-6 years -> Taking 5 years (1825 days) 
    const years5 = Duration(days: 1825);
    
    // 10 years
    const years10 = Duration(days: 3650);
    
    // 16 years
    const years16 = Duration(days: 5840);
    
    return [
      // At Birth
      create("BCG", Duration.zero),
      create("Hepatitis B - Birth dose", Duration.zero),
      create("OPV-0", Duration.zero),
      
      // 6 Weeks
      create("OPV-1", weeks6),
      create("Pentavalent-1", weeks6),
      create("Rotavirus-1", weeks6),
      create("IPV-1 (Fractional)", weeks6), // Fractional Dose
      
      // 10 Weeks
      create("OPV-2", weeks10),
      create("Pentavalent-2", weeks10),
      create("Rotavirus-2", weeks10),
      
      // 14 Weeks
      create("OPV-3", weeks14),
      create("Pentavalent-3", weeks14),
      create("Rotavirus-3", weeks14),
      create("IPV-2 (Fractional)", weeks14), 

      // 9-12 Months
      create("Measles / MR 1st Dose", months9),
      create("JE - 1", months9),
      create("Vitamin A (1st dose)", months9),

      // 16-24 Months
      create("DPT Booster-1", months16),
      create("Measles / MR 2nd Dose", months16),
      create("OPV Booster", months16),
      create("JE - 2", months16),
      create("Vitamin A (2nd dose)", months16),
      
      // Vitamin A (2nd to 9th dose) - every 6 months until 5 years.
      // 2nd dose is at 16 months (above). 
      // 3rd: 22m, 4th: 28m, 5th: 34m, 6th: 40m, 7th: 46m, 8th: 52m, 9th: 58m (~5yr)
      create("Vitamin A (3rd dose)", const Duration(days: 480 + 180)),
      create("Vitamin A (4th dose)", const Duration(days: 480 + 360)),
      create("Vitamin A (5th dose)", const Duration(days: 480 + 540)),
      create("Vitamin A (6th dose)", const Duration(days: 480 + 720)),
      create("Vitamin A (7th dose)", const Duration(days: 480 + 900)),
      create("Vitamin A (8th dose)", const Duration(days: 480 + 1080)),
      create("Vitamin A (9th dose)", const Duration(days: 480 + 1260)),

      // 5-6 Years
      create("DPT Booster-2", years5),
      
      // 10 Years
      create("TT", years10),
      
      // 16 Years
      create("TT", years16),
    ];
  }
}
