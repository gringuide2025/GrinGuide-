import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'models/child_model.dart';
import 'models/parent_model.dart';

final profileRepositoryProvider = Provider((ref) => ProfileRepository(
      FirebaseFirestore.instance,
      FirebaseAuth.instance,
    ));

class ProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ProfileRepository(this._firestore, this._auth);

  String get currentUserId => _auth.currentUser?.uid ?? '';

  // Parent Methods
  Future<void> updateParentProfile(ParentModel parent) async {
    await _firestore.collection('parents').doc(parent.uid).set(parent.toMap(), SetOptions(merge: true));
  }

  Future<ParentModel?> getParentProfile() async {
    final doc = await _firestore.collection('parents').doc(currentUserId).get();
    if (doc.exists) {
      return ParentModel.fromMap(doc.data()!);
    }
    return null;
  }

  // Child Methods
  Stream<List<ChildModel>> getChildren() {
    return _firestore
        .collection('children')
        .where('parentId', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ChildModel.fromMap(doc.data())).toList();
    });
  }

  Future<void> addChild(ChildModel child, File? imageFile) async {
    String? photoUrl;
    if (imageFile != null) {
      photoUrl = await _saveImageLocally(imageFile, child.id);
    }

    final childWithPhoto = ChildModel(
      id: child.id,
      parentId: currentUserId,
      name: child.name,
      dob: child.dob,
      height: child.height,
      weight: child.weight,
      profilePhotoUrl: photoUrl,
    );

    await _firestore.collection('children').doc(child.id).set(childWithPhoto.toMap());
  }

  Future<void> updateChild(ChildModel child, File? imageFile) async {
    String? photoUrl = child.profilePhotoUrl;
    if (imageFile != null) {
      photoUrl = await _saveImageLocally(imageFile, child.id);
    }

    final updatedChild = ChildModel(
      id: child.id,
      parentId: child.parentId,
      name: child.name,
      dob: child.dob,
      height: child.height,
      weight: child.weight,
      profilePhotoUrl: photoUrl,
    );
     await _firestore.collection('children').doc(child.id).update(updatedChild.toMap());
  }

  Future<void> deleteChild(String childId) async {
    await _firestore.collection('children').doc(childId).delete();
    // Optional: Delete local file. Complicated if path not known without reading first.
  }

  Future<void> deleteChildProfilePhoto(String childId) async {
    // 1. Update Firestore to null
    await _firestore.collection('children').doc(childId).update({'profilePhotoUrl': null});
    // 2. Try to find and delete local file (best effort)
    final directory = await getApplicationDocumentsDirectory();
    final String path = '${directory.path}/child_$childId.jpg';
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<String> _saveImageLocally(File image, String childId) async {
    // Save to Application Documents Directory
    final directory = await getApplicationDocumentsDirectory();
    final String path = '${directory.path}/child_$childId.jpg';
    final File localImage = await image.copy(path); 
    return localImage.path;
  }
}
