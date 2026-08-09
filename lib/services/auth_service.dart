import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_task_manager_app/core/constants/app_constants.dart';
import 'package:student_task_manager_app/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current Firebase user
  User? get currentUser => _auth.currentUser;

  /// Sign Up with email, password, and name
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) return null;

    // Update display name in Firebase Auth
    await user.updateDisplayName(name);

    // Save user profile to Firestore
    final userModel = UserModel(
      uid: user.uid,
      name: name,
      email: email,
    );

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set(userModel.toMap());

    return userModel;
  }

  /// Sign In with email and password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Get user profile from Firestore
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();

    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromMap(doc.data()!);
  }

  /// Update user name
  Future<void> updateUserName(String uid, String name) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update({'name': name});

    await currentUser?.updateDisplayName(name);
  }

  /// Update profile image URL
  Future<void> updateProfileImageUrl(String uid, String imageUrl) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update({'profileImageUrl': imageUrl});

    await currentUser?.updatePhotoURL(imageUrl);
  }
}
