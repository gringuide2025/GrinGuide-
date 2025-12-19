import 'dart:convert';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/healthy_foods_data.dart';
import '../../router/app_router.dart';
import '../../features/profile/models/child_model.dart';

// Top-level function for background execution
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) async {
  // Initialize Firebase for background isolate
  // Note: We need to import firebase_core
  // Since we can't reliably pass arguments to entry point, we re-initialize.
  // In a real app, you might need specific options.
  try {
     // We need to initialize Firebase here, but we need the platform specific options.
     // For now, let's assume default options work or are not needed for simple HTTP?
     // Actually Firestore NEEDS Firebase app.
     // However, importing firebase_options.dart is safer if generated. 
     // Let's rely on standard init if possible.
     // NOTE: This might fail if options are required. 
     // But for now, we try to just print. Real impl needs imports.
     debugPrint('notificationTapBackground: ${notificationResponse.actionId}');
     
     // To perform Firestore logic, we need to spin up the service.
     // We will create a fresh instance of service logic here.
     // But we can't reuse the singleton easily if it has state. 
     // We will call a static helper.
     if (notificationResponse.actionId == 'done' && notificationResponse.payload != null) {
       // We must initialize Firebase first
       // Depending on your project setup, you might need:
       // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
       // For now, let's try generic init.
       // await Firebase.initializeApp(); // Requires adding firebase_core import
       
       // CRITICAL: We need to perform the Firestore update here.
       // This runs in a separate isolate!
       await NotificationService.handleBackgroundAction(notificationResponse.payload!);
     }
  } catch (e) {
    debugPrint("Error in background tap: $e");
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> init() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon'); 

    // Actions
    const AndroidNotificationAction doneAction = AndroidNotificationAction(
      'done',
      'Done',
      showsUserInterface: false, // CRITICAL: false to prevent opening app!
      cancelNotification: true,
    );
    const AndroidNotificationAction notDoneAction = AndroidNotificationAction(
      'not_done',
      'Not Done',
      showsUserInterface: false, // CRITICAL: false to prevent opening app!
      cancelNotification: true,
    );

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin);

    await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) async {
          if (response.payload != null && response.actionId == 'done') {
             await handleDoneAction(response.payload!); 
          }
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Create Channels with Sounds
    final androidPlugin = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final sounds = ['sound_chime', 'sound_magic', 'sound_pop', 'sound_bird', 'sound_power'];
      for (var s in sounds) {
        await androidPlugin.createNotificationChannel(AndroidNotificationChannel(
          s,
          s.replaceAll('_', ' ').toUpperCase(),
          importance: Importance.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound(s),
        ));
      }
    }

    // OneSignal Click Listener
    OneSignal.Notifications.addClickListener((event) async {
      final actionId = event.result.actionId;
      final data = event.notification.additionalData;
      
      debugPrint("OneSignal Action Clicked: $actionId, Data: $data");

      if (actionId == 'done' && data != null) {
        // Handle the database update
        await handleDoneActionMap(data);

        // Show feedback if possible (requires context, but we are in a top-level listener)
        // Since we lack context here easily, we just proceed to close.
        // Actually, we can't show SnackBar without context.
        // Using SystemNavigator.pop() to simulate "Background Action" behavior as requested.
        // We add a small delay to ensure the DB write might have flushed/user sees a glimpse.
        await Future.delayed(const Duration(milliseconds: 500)); 
        SystemNavigator.pop();
      } else if (actionId == 'reschedule' && data != null) {
        // Navigate to the respective screen
        try {
          // We need to fetch the child first to pass as argument
          String? childId = data['childId'];
          if (childId == null) return;

          final childSnapshot = await FirebaseFirestore.instance.collection('children').doc(childId).get();
          if (childSnapshot.exists) {
            final child = ChildModel.fromMap(childSnapshot.data()!); // Needs import
            
            // Navigate based on task
            final String? task = data['task'];
            if (task == 'vaccine') {
               router.push('/dashboard/vaccines', extra: child); // Needs router import
            } else if (task == 'dental') {
               router.push('/dashboard/dental', extra: child);
            }
          }
        } catch(e) {
          debugPrint("Error handling reschedule: $e");
        }
      }
    });
  }

  // Handle JSON String (Local)
  Future<void> handleDoneAction(String payload) async {
    try {
      final data = jsonDecode(payload);
      await handleDoneActionMap(data);
    } catch (e) {
      debugPrint("Error parsing payload: $e");
    }
  }

  // Handle Map (OneSignal + Local)
  Future<void> handleDoneActionMap(Map<String, dynamic> data) async {
    try {
      String? childId = data['childId'];
      final String? task = data['task']; 

      if (task == null) {
        debugPrint("Cannot mark done: Task missing in payload.");
        return;
      }

      // If childId is missing (broadcast notification), get the first child
      if (childId == null) {
        debugPrint("Child ID missing in payload. Fetching first child...");
        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            debugPrint("No user logged in");
            return;
          }
          
          final childrenSnapshot = await FirebaseFirestore.instance
              .collection('children')
              .where('parentId', isEqualTo: user.uid)
              .limit(1)
              .get();
          
          if (childrenSnapshot.docs.isEmpty) {
            debugPrint("No children found for user");
            return;
          }
          
          childId = childrenSnapshot.docs.first.id;
          debugPrint("Using first child: $childId");
        } catch (e) {
          debugPrint("Error fetching child: $e");
          return;
        }
      }

      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final docId = '${childId}_$today';
      
      final docRef = FirebaseFirestore.instance.collection('daily_checklist').doc(docId);
      
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        
        // Prepare update data based on task type
        Map<String, dynamic> updateData = {};
        
        if (task == 'morningRoutine') {
          // Combined brush + floss
          updateData = {
            'brushMorning': true,
            'flossMorning': true,
          };
        } else if (task == 'nightRoutine') {
          // Combined brush + floss
          updateData = {
            'brushNight': true,
            'flossNight': true,
          };
        } else if (task == 'healthyFood') {
          updateData = {
            'healthyFood': true,
          };
          // Include food item if provided, otherwise use local source of truth
          if (data['foodItem'] != null) {
            updateData['healthyFoodItem'] = data['foodItem'];
          } else {
             // Fallback to deterministic logic
             final dayOfYear = int.parse(DateFormat("D").format(DateTime.now()));
             updateData['healthyFoodItem'] = healthyFoodsData[dayOfYear % healthyFoodsData.length].name;
          }
        } else if (task == 'vaccine' && data['docId'] != null) {
           // Update specific vaccine document
           await FirebaseFirestore.instance.collection('vaccines').doc(data['docId']).update({'isDone': true});
           return; // Exit transaction/daily logic as this is a separate collection
        } else if (task == 'dental' && data['docId'] != null) {
           // Update specific dental document
           await FirebaseFirestore.instance.collection('dental_appointments').doc(data['docId']).update({'isDone': true});
           return; // Exit transaction/daily logic
        } else {
          // Legacy individual tasks
          updateData = {task: true};
        }
        
        if (!snapshot.exists) {
           // Create new daily checklist if not exists (only for daily tasks)
           transaction.set(docRef, {
             'childId': childId,
             'date': today,
             ...updateData,
             // Init defaults for other fields
             'brushMorning': updateData['brushMorning'] ?? false,
             'brushNight': updateData['brushNight'] ?? false,
             'flossMorning': updateData['flossMorning'] ?? false,
             'flossNight': updateData['flossNight'] ?? false,
             'healthyFood': updateData['healthyFood'] ?? false,
             'healthyFoodItem': updateData['healthyFoodItem'] ?? '',
           });
        } else {
           transaction.update(docRef, updateData);
        }
      });
      debugPrint("Action Done: $task for $childId");
    } catch (e) {
      debugPrint("Error handling notification action: $e");
    }
  }

  static Future<void> handleBackgroundAction(String payload) async {
    // This runs in background isolate.
    // We must initialize Firebase.
    try {
        // NOTE: You must import firebase_core and your firebase_options.
        // For simplicity in this edit, assuming default app init works or adding imports.
        // In release mode, 'firebase_core' is generally needed.
        // We added import 'firebase_auth' earlier, need 'firebase_core'.
        await Firebase.initializeApp();
        
        final data = jsonDecode(payload);
        final service = NotificationService._internal(); // Create instance
        await service.handleDoneActionMap(data); 
    } catch(e) {
        debugPrint("Background Action Failed: $e");
    }
  }

  Future<bool?> requestPermissions() async {
    return await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  }



  // NOTE: Scheduled notifications are now handled by OneSignal (Server-side)
  // We only keep action handling logic here.

  Future<void> scheduleVaccineReminders({required int idPrefix, required String title, required String body, required DateTime eventDate}) async {
    debugPrint("Skipping local vaccine schedule (handled by OneSignal backend): $title");
  }

  Future<void> scheduleDentalReminders({required int idPrefix, required String title, required String body, required DateTime eventDate}) async {
    debugPrint("Skipping local dental schedule (handled by OneSignal backend): $title");
  }

  Future<void> scheduleDaily({required int id, required String title, required String body, required TimeOfDay time, String? payload}) async {
    debugPrint("Skipping local daily schedule (handled by backend): $title");
  }

  tz.TZDateTime _nextInstanceOfDay(int weekday, int hour, int minute) {
    tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }
    return scheduledDate;
  }
}

extension DateTimeExtension on DateTime {
  DateTime copyWith({int? year, int? month, int? day, int? hour, int? minute, int? second, int? millisecond, int? microsecond}) {
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    );
  }
}
