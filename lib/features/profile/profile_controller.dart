import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'models/child_model.dart';
import 'models/parent_model.dart';
import 'profile_repository.dart';

final parentProfileProvider = FutureProvider<ParentModel?>((ref) async {
  return ref.watch(profileRepositoryProvider).getParentProfile();
});

final childrenProvider = StreamProvider<List<ChildModel>>((ref) {
  return ref.watch(profileRepositoryProvider).getChildren();
});

final profileControllerProvider = StateNotifierProvider<ProfileController, AsyncValue<void>>((ref) {
  return ProfileController(ref.watch(profileRepositoryProvider));
});

class ProfileController extends StateNotifier<AsyncValue<void>> {
  final ProfileRepository _repository;

  ProfileController(this._repository) : super(const AsyncValue.data(null));

  Future<void> saveParentProfile(String fatherName, String motherName, String email, String password) async {
    state = const AsyncValue.loading();
    final parent = ParentModel(
      uid: _repository.currentUserId,
      fatherName: fatherName,
      motherName: motherName,
      email: email,
      password: password.isNotEmpty ? password : null,
    );
    state = await AsyncValue.guard(() => _repository.updateParentProfile(parent));
  }

  Future<void> addChild({
    required String name,
    required DateTime dob,
    required double height,
    required double weight,
    File? imageFile,
    String gender = 'boy',
  }) async {
    state = const AsyncValue.loading();
    final childId = const Uuid().v4();
    final child = ChildModel(
      id: childId,
      parentId: _repository.currentUserId,
      name: name,
      dob: dob,
      height: height,
      weight: weight,
      gender: gender,
    );
    state = await AsyncValue.guard(() => _repository.addChild(child, imageFile));
  }
  
  Future<void> updateChild({
    required String id,
    required String name,
    required DateTime dob,
    required double height,
    required double weight,
    String? currentPhotoUrl,
    File? imageFile,
    required String parentId,
    String gender = 'boy',
  }) async {
    state = const AsyncValue.loading();
     final child = ChildModel(
      id: id,
      parentId: parentId,
      name: name,
      dob: dob,
      height: height,
      weight: weight,
      profilePhotoUrl: currentPhotoUrl,
      gender: gender,
    );
    state = await AsyncValue.guard(() => _repository.updateChild(child, imageFile));
  }

  Future<void> deleteChild(String childId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.deleteChild(childId));
  }

  Future<void> deleteChildPhoto(String childId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.deleteChildProfilePhoto(childId));
  }
}
