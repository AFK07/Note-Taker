import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  User? get user => _user;

  // Constructor to listen to auth state changes
  AuthService() {
    _user = _auth.currentUser;
    _auth.authStateChanges().listen((User? newUser) {
      _user = newUser;
      notifyListeners();
    });
  }

  // Check if user is logged in
  bool get isLoggedIn => _user != null;

  /// Sign up with email and password
  Future<String?> signUp(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      _user = credential.user;
      await _user?.reload(); // ensure info is fresh
      _user = _auth.currentUser;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ SignUp Error [${e.code}]: ${e.message}');
      return _getFriendlyError(e.code, e.message);
    } catch (e) {
      debugPrint('❌ Unexpected SignUp Error: $e');
      return 'An unexpected error occurred during sign up.';
    }
  }

  /// Sign in with email and password
  Future<String?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      _user = credential.user;
      await _user?.reload();
      _user = _auth.currentUser;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ SignIn Error [${e.code}]: ${e.message}');
      return _getFriendlyError(e.code, e.message);
    } catch (e) {
      debugPrint('❌ Unexpected SignIn Error: $e');
      return 'An unexpected error occurred during sign in.';
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  /// Friendly error messages
  String _getFriendlyError(String code, String? message) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled in Firebase.';
      case 'weak-password':
        return 'The password is too weak. Use at least 6 characters.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'configuration-not-found':
        return 'Firebase authentication is not configured correctly.';
      default:
        return message ?? 'Authentication error. Please try again.';
    }
  }
}
