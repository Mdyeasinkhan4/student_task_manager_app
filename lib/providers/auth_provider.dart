import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:student_task_manager_app/controller/auth_controller.dart';
import 'package:student_task_manager_app/data/model/api_response.dart';
import 'package:student_task_manager_app/data/model/user_model.dart';
import 'package:student_task_manager_app/data/service/api_caller.dart';
import 'package:student_task_manager_app/utils/urls.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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

    try {
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
    String? photo,
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

      if (photo != null && photo.isNotEmpty) {
        body['photo'] = photo;
      }

      if (password != null && password.isNotEmpty) {
        body['password'] = password;
      }

      final ApiResponse response = await ApiCaller.PostRequest(
        url: TMUrls.updateProfileURL,
        body: body,
      );

      debugPrint('Profile Update Response: ${response.responseCode} - ${response.responseData}');

      if (response.isSuccess) {
        final updatedUser = UserModel(
          sId: _user?.sId,
          email: email,
          firstName: firstName,
          lastName: lastName,
          mobile: mobile,
          photo: photo ?? _user?.photo,
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
      if (!kIsWeb) {
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
      UserCredential userCredential;
      
      if (kIsWeb) {
        // Web flow using Popup
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        userCredential = await _firebaseAuth.signInWithPopup(googleProvider);
      } else {
        // Mobile flow
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          _isLoading = false;
          notifyListeners();
          return false;
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        userCredential = await _firebaseAuth.signInWithCredential(credential);
      }

      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final String token = await firebaseUser.getIdToken() ?? '';
      final String displayName = firebaseUser.displayName ?? '';
      final List<String> nameParts = displayName.split(' ');
      
      final UserModel user = UserModel(
        sId: firebaseUser.uid,
        email: firebaseUser.email,
        firstName: nameParts.isNotEmpty ? nameParts.first : '',
        lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
        mobile: firebaseUser.phoneNumber,
      );

      await AuthController.saveUserData(user, token);
      _user = user;
      _token = token;
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      debugPrint('Google Sign-In Error: $error');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
