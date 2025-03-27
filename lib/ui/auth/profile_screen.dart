import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  Future<void> _authenticate() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        (!_isLogin &&
            (_firstNameController.text.trim().isEmpty ||
                _lastNameController.text.trim().isEmpty ||
                _dob == null ||
                _gender == null))) {
      setState(() => _message = '❌ Please fill all required fields');
      return;
    }

    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        setState(() => _message = '✅ Logged in successfully!');
        _showSnackBar('✅ Logged in successfully!', Colors.green);
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
        }

        setState(() => _message = '✅ Account created and info saved!');
        _showSnackBar('✅ Account created and info saved!', Colors.green);
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code} | ${e.message}');
      final msg = _getFriendlyMessage(e.code, e.message);
      setState(() => _message = '❌ $msg');
      _showSnackBar('❌ $msg', Colors.red);
    } catch (e) {
      debugPrint('Unexpected error: $e');
      const msg = '❌ Something went wrong';
      setState(() => _message = msg);
      _showSnackBar(msg, Colors.red);
    }
  }

  void _showSnackBar(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: color),
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
      default:
        return fallback ?? 'An authentication error occurred.';
    }
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
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? "Login" : "Register")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: user == null
              ? SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!_isLogin) ...[
                        _buildHalfWidthField(
                          TextField(
                            controller: _firstNameController,
                            decoration:
                                const InputDecoration(labelText: 'First Name'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildHalfWidthField(
                          TextField(
                            controller: _lastNameController,
                            decoration:
                                const InputDecoration(labelText: 'Last Name'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildHalfWidthField(
                          Row(
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
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildHalfWidthField(
                          DropdownButtonFormField<String>(
                            value: _gender,
                            hint: const Text("Select Gender"),
                            onChanged: (value) =>
                                setState(() => _gender = value),
                            items: const [
                              DropdownMenuItem(
                                  value: "Male", child: Text("Male")),
                              DropdownMenuItem(
                                  value: "Female", child: Text("Female")),
                              DropdownMenuItem(
                                  value: "Other", child: Text("Other")),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      _buildHalfWidthField(
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildHalfWidthField(
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration:
                              const InputDecoration(labelText: 'Password'),
                        ),
                      ),
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
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.account_circle, size: 100),
                    const SizedBox(height: 20),
                    Text(
                      "Logged in as:\n${user.email ?? user.uid}",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        setState(() {
                          _emailController.clear();
                          _passwordController.clear();
                          _firstNameController.clear();
                          _lastNameController.clear();
                          _dob = null;
                          _gender = null;
                          _message = '';
                        });
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text("Sign Out"),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
