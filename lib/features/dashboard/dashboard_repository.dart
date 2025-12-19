import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'models/daily_checklist_model.dart';
import '../profile/models/child_model.dart';
import '../../shared/constants/healthy_foods_data.dart';

final dashboardRepositoryProvider = Provider((ref) => DashboardRepository(FirebaseFirestore.instance));

class DashboardRepository {
  final FirebaseFirestore _firestore;

  DashboardRepository(this._firestore);

  String get _currentDate => DateFormat('yyyy-MM-dd').format(DateTime.now());

  Stream<DailyChecklistModel> getDailyChecklist(ChildModel child) {
    final docId = '${child.id}_$_currentDate';
    return _firestore.collection('daily_checklist').doc(docId).snapshots().map((doc) {
      if (doc.exists) {
        return DailyChecklistModel.fromMap(doc.data()!);
      } else {
        // Return default empty model if not exists (UI should handle init)
        return DailyChecklistModel(
          date: _currentDate, 
          childId: child.id, 
          parentId: child.parentId,
          healthyFoodItem: _getDailyHealthyFood()
        );
      }
    });
  }

  Future<void> updateChecklist(DailyChecklistModel model) async {
    final docId = '${model.childId}_${model.date}';
    
    // Save to daily_checklist (Current State)
    await _firestore.collection('daily_checklist').doc(docId).set(model.toMap(), SetOptions(merge: true));
    
    // Save to history (Daily Logs)
    // We strive for consistency, so we'll store a separate log document.
    // This allows us to query ranges easily without filtering the main checklist collection which might have other metadata.
    final logDocId = '${model.childId}_${model.date}';
    final log = {
      'date': model.date,
      'childId': model.childId,
      'brushedMorning': model.brushMorning,
      'flossedMorning': model.flossMorning,
      'ateHealthy': model.healthyFood,
      'brushedNight': model.brushNight,
      'flossedNight': model.flossNight,
    };
    await _firestore.collection('children').doc(model.childId).collection('daily_logs').doc(model.date).set(log, SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> getWeeklyLogs(String childId) async {
    final now = DateTime.now();
    List<Map<String, dynamic>> logs = [];

    // Fetch last 7 days including today
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final docId = '${childId}_$dateStr';

      try {
        final doc = await _firestore.collection('daily_checklist').doc(docId).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          // Map to format expected by ReportScreen
          logs.add({
            'date': data['date'] ?? dateStr, // Ensure date exists
            'childId': childId,
            'brushedMorning': data['brushMorning'] ?? false,
            'brushedNight': data['brushNight'] ?? false,
            'flossedMorning': data['flossMorning'] ?? false,
            'flossedNight': data['flossNight'] ?? false,
            'ateHealthy': data['healthyFood'] ?? false,
          });
        }
      } catch (e) {
        // Ignore single doc errors (or permission denied on single doc, though unlikely if others work)
        debugPrint("Error fetching log for $dateStr: $e");
      }
    }
    
    // Sort by date descending (or ascending as per UI? UI uses ListView.builder, seemingly implicit order)
    // The loop adds them in chronological order (oldest first if i=6..0), which is usually what graphs/lists want.
    return logs;
  }

  String _getDailyHealthyFood() {
    final dayOfYear = int.parse(DateFormat("D").format(DateTime.now()));
    // Use the shared constant list
    return healthyFoodsData[dayOfYear % healthyFoodsData.length].name;
  }
}

final dailyChecklistProvider = StreamProvider.family<DailyChecklistModel, ChildModel>((ref, child) {
  return ref.watch(dashboardRepositoryProvider).getDailyChecklist(child);
});
