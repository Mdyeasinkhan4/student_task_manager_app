import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:student_task_manager_app/controller/auth_controller.dart';
import 'package:student_task_manager_app/data/model/api_response.dart';
import 'package:student_task_manager_app/data/model/user_model.dart';
import 'package:student_task_manager_app/data/service/api_caller.dart';
import 'package:student_task_manager_app/utils/urls.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  bool _isInitializing = false;

  UserModel? get user => _user;
  bool get isAuthenticated => _token != null && _user != null;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;

  Future<void> initialize() async {
    _isInitializing = true;
    notifyListeners();

    await AuthController.getUserData();
    _user = AuthController.userData;
    _token = AuthController.accessToken;

    _isInitializing = false;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();

    final ApiResponse response = await ApiCaller.PostRequest(
      url: TMUrls.SignInURL,
      body: {
        'email': email,
        'password': password,
      },
    );

    _isLoading = false;

    if (response.isSuccess) {
      final token = response.responseData['token']?.toString();
      final userData = response.responseData['data'];
      if (token != null && userData != null) {
        final user = UserModel.fromJson(userData);
        await AuthController.saveUserData(user, token);
        _user = user;
        _token = token;
        notifyListeners();
        return true;
      }
    }

    notifyListeners();
    return false;
  }

  Future<bool> signUp({
    required String email,
    required String firstName,
    required String lastName,
    required String mobile,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    final ApiResponse response = await ApiCaller.PostRequest(
      url: TMUrls.SignUpURL,
      body: {
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'mobile': mobile,
        'password': password,
      },
    );

    _isLoading = false;
    notifyListeners();
    return response.isSuccess;
  }

  Future<bool> updateProfile({
    required String email,
    required String firstName,
    required String lastName,
    required String mobile,
    String? password,
  }) async {
    if (_user == null) return false;

    _isLoading = true;
    notifyListeners();

    final body = {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'mobile': mobile,
    };
    if (password != null && password.isNotEmpty) {
      body['password'] = password;
    }

    final ApiResponse response = await ApiCaller.PostRequest(
      url: TMUrls.updateProfileURL,
      body: body,
    );

    _isLoading = false;

    if (response.isSuccess) {
      final updatedUser = UserModel(
        sId: _user?.sId,
        email: email,
        firstName: firstName,
        lastName: lastName,
        mobile: mobile,
      );
      await AuthController.updateUserData(updatedUser);
      _user = updatedUser;
      notifyListeners();
      return true;
    }

    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await AuthController.clearUserData();
    _user = null;
    _token = null;
    notifyListeners();
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null && googleAuth.accessToken == null) {
        return false;
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        return false;
      }

      final token = (await firebaseUser.getIdToken()) ?? '';
      final displayName = firebaseUser.displayName ?? '';
      final nameParts = displayName.split(' ');
      final user = UserModel(
        sId: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        firstName: nameParts.isNotEmpty ? nameParts.first : '',
        lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
        mobile: firebaseUser.phoneNumber,
        createdDate: firebaseUser.metadata.creationTime?.toIso8601String(),
      );

      await AuthController.saveUserData(user, token);
      _user = user;
      _token = token;
      notifyListeners();
      return true;
    } catch (error, stackTrace) {
      debugPrint('Google sign-in error: $error');
      debugPrint('$stackTrace');
      await _googleSignIn.signOut();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
