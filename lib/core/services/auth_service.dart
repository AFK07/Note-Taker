import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  User? get user => _user;

  // Check login state stream
  AuthService() {
    _auth.authStateChanges().listen((User? newUser) {
      _user = newUser;
      notifyListeners(); // Notifies UI of auth state changes
    });
  }

  // 📌 Helper: Is user logged in?
  bool get isLoggedIn => _user != null;

  // 🔐 Sign Up with Email & Password
  Future<String?> signUp(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      _user = credential.user;
      notifyListeners();
      return null; // Success
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ SignUp Error [${e.code}]: ${e.message}');
      return _getFriendlyError(e.code, e.message);
    } catch (e) {
      debugPrint('❌ Unexpected SignUp Error: $e');
      return 'An unexpected error occurred during sign up.';
    }
  }

  // 🔓 Sign In with Email & Password
  Future<String?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      _user = credential.user;
      notifyListeners();
      return null; // Success
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ SignIn Error [${e.code}]: ${e.message}');
      return _getFriendlyError(e.code, e.message);
    } catch (e) {
      debugPrint('❌ Unexpected SignIn Error: $e');
      return 'An unexpected error occurred during sign in.';
    }
  }

  // 🚪 Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  // 🧠 Translate Firebase error codes
  String _getFriendlyError(String code, String? message) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'weak-password':
        return 'The password is too weak. Use at least 6 characters.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return message ?? 'Authentication error. Please try again.';
    }
  }
}
