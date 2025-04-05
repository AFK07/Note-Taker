import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'account_detail.dart'; // ✅ Correct import for LoggedInScreen

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  DateTime? _dob;
  String? _gender;
  bool _isLogin = true;
  String _message = '';
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        (!_isLogin &&
            (_firstNameController.text.trim().isEmpty ||
                _lastNameController.text.trim().isEmpty ||
                _dob == null ||
                _gender == null))) {
      _showSnackBar('❌ Please fill all required fields', Colors.red);
      return;
    }

    try {
      if (_isLogin) {
        final userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        _showSnackBar('✅ Logged in successfully!', Colors.green);
        _navigateToLoggedIn(userCredential.user!);
      } else {
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final user = credential.user;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'firstName': _firstNameController.text.trim(),
            'lastName': _lastNameController.text.trim(),
            'dob': _dob?.toIso8601String(),
            'gender': _gender,
            'email': user.email,
            'createdAt': FieldValue.serverTimestamp(),
          });
          _showSnackBar('✅ Account created and info saved!', Colors.green);
          _navigateToLoggedIn(user);
        }
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code} | ${e.message}');
      final msg = _getFriendlyMessage(e.code, e.message);
      _showSnackBar('❌ $msg', Colors.red);
    } catch (e) {
      debugPrint('Unexpected error: $e');
      _showSnackBar('❌ Something went wrong', Colors.red);
    }
  }

  void _navigateToLoggedIn(User user) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoggedInScreen(user: user)),
    );
  }

  String _getFriendlyMessage(String code, String? fallback) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'network-request-failed':
        return 'Check your internet connection.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'configuration-not-found':
        return 'Firebase Auth is not properly configured.';
      default:
        return fallback ?? 'An authentication error occurred.';
    }
  }

  void _showSnackBar(String message, Color color) {
    setState(() => _message = message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Future<void> _pickDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _dob = picked);
    }
  }

  Widget _buildHalfWidthField(Widget child) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? "Login" : "Register")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_isLogin) ...[
                  _buildHalfWidthField(TextField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(labelText: 'First Name'),
                  )),
                  const SizedBox(height: 10),
                  _buildHalfWidthField(TextField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: 'Last Name'),
                  )),
                  const SizedBox(height: 10),
                  _buildHalfWidthField(Row(
                    children: [
                      Expanded(
                        child: Text(
                          _dob == null
                              ? "Select Date of Birth"
                              : "DOB: ${_dob!.toLocal().toString().split(' ')[0]}",
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: _pickDateOfBirth,
                      ),
                    ],
                  )),
                  const SizedBox(height: 10),
                  _buildHalfWidthField(DropdownButtonFormField<String>(
                    value: _gender,
                    hint: const Text("Select Gender"),
                    onChanged: (value) => setState(() => _gender = value),
                    items: const [
                      DropdownMenuItem(value: "Male", child: Text("Male")),
                      DropdownMenuItem(value: "Female", child: Text("Female")),
                      DropdownMenuItem(value: "Other", child: Text("Other")),
                    ],
                  )),
                  const SizedBox(height: 10),
                ],
                _buildHalfWidthField(TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                )),
                const SizedBox(height: 10),
                _buildHalfWidthField(TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                )),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _authenticate,
                  child: Text(_isLogin ? 'Login' : 'Register'),
                ),
                TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(_isLogin
                      ? "Don't have an account? Register"
                      : "Already have an account? Login"),
                ),
                const SizedBox(height: 10),
                Text(
                  _message,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
