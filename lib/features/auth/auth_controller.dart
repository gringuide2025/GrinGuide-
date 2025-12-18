import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;

  AuthController(this._authRepository) : super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
       await _authRepository.signInWithEmailAndPassword(email, password);
       
       // Link Firebase UID with OneSignal External User ID
       final user = FirebaseAuth.instance.currentUser;
       if (user != null) {
         OneSignal.login(user.uid);
       }
       
       final prefs = await SharedPreferences.getInstance();
       await prefs.setString('last_forced_login', DateTime.now().toIso8601String());
    });
  }

  Future<void> signup(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authRepository.signUpWithEmailAndPassword(email, password);
      
      // Link Firebase UID with OneSignal External User ID
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        OneSignal.login(user.uid);
      }
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_forced_login', DateTime.now().toIso8601String());
    });
  }

  Future<UserCredential?> googleSignIn() async {
    state = const AsyncValue.loading();
    UserCredential? credential;
    state = await AsyncValue.guard(() async {
      credential = await _authRepository.signInWithGoogle();
      
      if (credential != null && credential!.user != null) {
        final user = credential!.user!;
        
        // Link Firebase UID with OneSignal External User ID
        OneSignal.login(user.uid);
        
        // Save/Update user profile in Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoUrl': user.photoURL,
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_forced_login', DateTime.now().toIso8601String());
      }
    });
    return credential;
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _authRepository.signOut());
  }

   Future<void> forgotPassword(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _authRepository.sendPasswordResetEmail(email));
  }
}
