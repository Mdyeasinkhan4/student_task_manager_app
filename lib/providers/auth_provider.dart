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
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  bool _isInitializing = false;
  bool _googleSignInInitialized = false;

  UserModel? get user => _user;
  bool get isAuthenticated => _token != null && _user != null;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;

  Future<void> initialize() async {
    _isInitializing = true;
    notifyListeners();

    try {
      if (!_googleSignInInitialized) {
        await _googleSignIn.initialize();
        _googleSignInInitialized = true;
      }

      await AuthController.getUserData();
      _user = AuthController.userData;
      _token = AuthController.accessToken;
    } catch (error, stackTrace) {
      debugPrint('Auth initialization error: $error');
      debugPrint('$stackTrace');
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final ApiResponse response = await ApiCaller.PostRequest(
        url: TMUrls.SignInURL,
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.isSuccess) {
        final token = response.responseData['token']?.toString();
        final userData = response.responseData['data'];

        if (token != null && userData != null) {
          final user = UserModel.fromJson(userData);
          await AuthController.saveUserData(user, token);
          _user = user;
          _token = token;
          return true;
        }
      }

      return false;
    } catch (error, stackTrace) {
      debugPrint('Login error: $error');
      debugPrint('$stackTrace');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

    try {
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

      return response.isSuccess;
    } catch (error, stackTrace) {
      debugPrint('Sign-up error: $error');
      debugPrint('$stackTrace');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

    try {
      final Map<String, dynamic> body = {
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
        return true;
      }

      return false;
    } catch (error, stackTrace) {
      debugPrint('Update profile error: $error');
      debugPrint('$stackTrace');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await AuthController.clearUserData();
      await _firebaseAuth.signOut();
      if (_googleSignInInitialized) {
        await _googleSignIn.signOut();
      }
    } catch (error, stackTrace) {
      debugPrint('Logout error: $error');
      debugPrint('$stackTrace');
    } finally {
      _user = null;
      _token = null;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle() async {

    
    _isLoading = true;
    notifyListeners();

    try {
      if (!_googleSignInInitialized) {
        await _googleSignIn.initialize();
        _googleSignInInitialized = true;
      }

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        debugPrint('Google sign-in failed: ID token is null or empty.');
        return false;
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        debugPrint('Firebase returned no user after Google sign-in.');
        return false;
      }

      final String token = await firebaseUser.getIdToken() ?? '';
      if (token.isEmpty) {
        debugPrint('Firebase ID token is empty.');
        return false;
      }

      final String displayName = firebaseUser.displayName ?? '';
      final List<String> nameParts = displayName
          .trim()
          .split(RegExp(r'\s+'))
          .where((name) => name.isNotEmpty)
          .toList();
      final String firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final String lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final UserModel user = UserModel(
        sId: firebaseUser.uid,
        email: firebaseUser.email ?? googleUser.email,
        firstName: firstName,
        lastName: lastName,
        mobile: firebaseUser.phoneNumber,
        createdDate: firebaseUser.metadata.creationTime?.toIso8601String(),
      );

      await AuthController.saveUserData(user, token);
      _user = user;
      _token = token;
      return true;
    } on GoogleSignInException catch (error, stackTrace) {
      debugPrint('Google sign-in exception: $error');
      debugPrint('$stackTrace');
      return false;
    } on FirebaseAuthException catch (error, stackTrace) {
      debugPrint('Firebase authentication error: ${error.code}');
      debugPrint(error.message ?? 'No Firebase error message.');
      debugPrint('$stackTrace');
      return false;
    } catch (error, stackTrace) {
      debugPrint('Google sign-in error: $error');
      debugPrint('$stackTrace');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
