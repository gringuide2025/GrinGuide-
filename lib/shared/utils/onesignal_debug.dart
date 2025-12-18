import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

/// Debug utility to check OneSignal Player ID status
class OneSignalDebug {
  /// Check and print OneSignal Player ID status
  static Future<Map<String, dynamic>> checkPlayerIdStatus() async {
    final result = <String, dynamic>{};
    
    try {
      // 1. Check Firebase Auth
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('❌ No user logged in');
        result['error'] = 'No user logged in';
        return result;
      }
      
      debugPrint('✅ Firebase User: ${user.uid}');
      debugPrint('   Email: ${user.email}');
      result['firebaseUid'] = user.uid;
      result['email'] = user.email;
      
      // 2. Check OneSignal External User ID
      final externalUserId = await OneSignal.User.getExternalId();
      debugPrint('🔍 OneSignal External User ID: $externalUserId');
      result['externalUserId'] = externalUserId;
      
      if (externalUserId == null || externalUserId.isEmpty) {
        debugPrint('⚠️ WARNING: OneSignal External User ID not set!');
        debugPrint('   This means OneSignal doesn\'t know the Firebase UID');
        debugPrint('   Backend notifications using External User ID will fail!');
        result['warning'] = 'External User ID not set';
      } else if (externalUserId != user.uid) {
        debugPrint('⚠️ WARNING: External User ID mismatch!');
        debugPrint('   Expected: ${user.uid}');
        debugPrint('   Got: $externalUserId');
        result['warning'] = 'External User ID mismatch';
      } else {
        debugPrint('✅ External User ID matches Firebase UID');
      }
      
      // 3. Check OneSignal Subscription ID (Player ID)
      final subscriptionId = OneSignal.User.pushSubscription.id;
      debugPrint('🔍 OneSignal Subscription ID (Player ID): $subscriptionId');
      result['subscriptionId'] = subscriptionId;
      
      if (subscriptionId == null || subscriptionId.isEmpty) {
        debugPrint('❌ No OneSignal Subscription ID available');
        debugPrint('   Possible reasons:');
        debugPrint('   - OneSignal not fully initialized');
        debugPrint('   - Notification permission not granted');
        debugPrint('   - Network issues');
        result['error'] = 'No subscription ID';
      } else {
        debugPrint('✅ OneSignal Subscription ID found: $subscriptionId');
      }
      
      // 4. Check if opted in for push notifications
      final optedIn = OneSignal.User.pushSubscription.optedIn;
      debugPrint('🔍 Push Notification Opted In: $optedIn');
      result['optedIn'] = optedIn;
      
      if (optedIn != true) {
        debugPrint('⚠️ User not opted in for push notifications');
      }
      
      // 5. Check Firestore for stored Player IDs
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (userDoc.exists) {
        final data = userDoc.data();
        final playerIds = data?['oneSignalPlayerIds'] as List?;
        
        debugPrint('🔍 Firestore User Document exists');
        debugPrint('   Player IDs in Firestore: $playerIds');
        result['firestorePlayerIds'] = playerIds;
        
        if (playerIds == null || playerIds.isEmpty) {
          debugPrint('⚠️ No player IDs stored in Firestore');
          result['warning'] = 'No player IDs in Firestore';
        } else {
          debugPrint('✅ Found ${playerIds.length} player ID(s) in Firestore');
          
          // Check if current subscription ID is in Firestore
          if (subscriptionId != null && !playerIds.contains(subscriptionId)) {
            debugPrint('⚠️ Current subscription ID not in Firestore!');
            debugPrint('   This might indicate registration failed');
            result['warning'] = 'Current subscription ID not in Firestore';
          }
        }
      } else {
        debugPrint('❌ User document does not exist in Firestore');
        result['error'] = 'User document not found in Firestore';
      }
      
      // 6. Summary
      debugPrint('\n📊 SUMMARY:');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      if (externalUserId == user.uid && 
          subscriptionId != null && 
          subscriptionId.isNotEmpty &&
          userDoc.exists &&
          (userDoc.data()?['oneSignalPlayerIds'] as List?)?.contains(subscriptionId) == true) {
        debugPrint('✅ OneSignal is FULLY CONFIGURED');
        debugPrint('   - External User ID: Set correctly');
        debugPrint('   - Subscription ID: Generated');
        debugPrint('   - Firestore: Stored correctly');
        result['status'] = 'success';
      } else {
        debugPrint('❌ OneSignal has ISSUES:');
        if (externalUserId != user.uid) {
          debugPrint('   ❌ External User ID not set or incorrect');
        }
        if (subscriptionId == null || subscriptionId.isEmpty) {
          debugPrint('   ❌ No subscription ID generated');
        }
        if (!userDoc.exists || (userDoc.data()?['oneSignalPlayerIds'] as List?)?.isEmpty == true) {
          debugPrint('   ❌ Player ID not stored in Firestore');
        }
        result['status'] = 'error';
      }
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      
    } catch (e, stack) {
      debugPrint('❌ Error checking OneSignal status: $e');
      debugPrint('Stack trace: $stack');
      result['error'] = e.toString();
      result['status'] = 'error';
    }
    
    return result;
  }
  
  /// Show a dialog with OneSignal status
  static Future<void> showStatusDialog(BuildContext context) async {
    final status = await checkPlayerIdStatus();
    
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('OneSignal Status'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusRow('Firebase UID', status['firebaseUid'] ?? 'Not found'),
              _buildStatusRow('Email', status['email'] ?? 'N/A'),
              const Divider(),
              _buildStatusRow('External User ID', status['externalUserId'] ?? '❌ Not set'),
              _buildStatusRow('Subscription ID', status['subscriptionId'] ?? '❌ Not generated'),
              _buildStatusRow('Opted In', status['optedIn']?.toString() ?? 'false'),
              const Divider(),
              _buildStatusRow('Firestore Player IDs', 
                (status['firestorePlayerIds'] as List?)?.join(', ') ?? '❌ None'),
              const Divider(),
              Text(
                status['status'] == 'success' 
                  ? '✅ All systems operational' 
                  : '❌ Issues detected',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: status['status'] == 'success' ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  static Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
