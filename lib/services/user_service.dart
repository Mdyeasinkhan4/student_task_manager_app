import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_task_manager_app/core/constants/app_constants.dart';
import 'package:student_task_manager_app/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Get user profile stream (real-time)
  Stream<UserModel?> getUserStream(String uid) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap(doc.data()!);
    });
  }

  /// Get user profile once
  Future<UserModel?> getUserOnce(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();

    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromMap(doc.data()!);
  }

  /// Update user name in Firestore
  Future<void> updateName(String uid, String name) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update({'name': name});
  }

  /// Upload profile image to Firebase Storage and update Firestore
  Future<String> uploadProfileImage(String uid, File imageFile) async {
    final ref = _storage.ref().child('profile_images/$uid.jpg');
    await ref.putFile(imageFile);
    final url = await ref.getDownloadURL();

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update({'profileImageUrl': url});

    return url;
  }

  /// Update user in Firestore
  Future<void> updateUser(UserModel user) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .update(user.toMap());
  }
}
