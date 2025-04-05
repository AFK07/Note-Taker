import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dart_app/ui/home/home_screen.dart';

class LoggedInScreen extends StatefulWidget {
  final User user;

  const LoggedInScreen({super.key, required this.user});

  @override
  State<LoggedInScreen> createState() => _LoggedInScreenState();
}

class _LoggedInScreenState extends State<LoggedInScreen> {
  bool isVerifying = false;
  late User currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = widget.user;
    _reloadUser();
  }

  Future<void> _reloadUser() async {
    await currentUser.reload();
    setState(() {
      currentUser = FirebaseAuth.instance.currentUser!;
    });
  }

  Future<void> _sendVerificationEmail() async {
    try {
      setState(() => isVerifying = true);
      await currentUser.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("📨 Verification email sent!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to send email: $e")),
      );
    } finally {
      setState(() => isVerifying = false);
    }
  }

  Future<void> _changeEmail() async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Change Email"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "New Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Current Password"),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final newEmail = emailController.text.trim();
              final password = passwordController.text.trim();
              Navigator.pop(context);

              try {
                final cred = EmailAuthProvider.credential(
                  email: currentUser.email!,
                  password: password,
                );
                await currentUser.reauthenticateWithCredential(cred);
                await currentUser.updateEmail(newEmail);
                await _reloadUser();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("✅ Email updated")),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("❌ Error: $e")),
                );
              }
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  Future<void> _changePassword() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Change Password"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "New Password"),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                await currentUser.updatePassword(controller.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("✅ Password updated")),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("❌ Error: $e")),
                );
              }
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      await currentUser.delete();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🗑 Account deleted")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVerified = currentUser.emailVerified;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Account Options'),
          actions: [
            IconButton(
              onPressed: _reloadUser,
              icon: const Icon(Icons.refresh),
              tooltip: "Refresh",
            )
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_circle, size: 100),
                const SizedBox(height: 20),
                Text(
                  "Logged in as:\n${currentUser.email ?? currentUser.uid}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  isVerified ? "✅ Email Verified" : "⚠ Email Not Verified",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isVerified ? Colors.green : Colors.orange,
                  ),
                ),
                if (!isVerified)
                  ElevatedButton.icon(
                    onPressed: isVerifying ? null : _sendVerificationEmail,
                    icon: const Icon(Icons.mark_email_unread),
                    label: Text(
                        isVerifying ? "Sending..." : "Send Verification Email"),
                  ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _changeEmail,
                  icon: const Icon(Icons.email),
                  label: const Text("📧 Change Email"),
                ),
                ElevatedButton.icon(
                  onPressed: _changePassword,
                  icon: const Icon(Icons.lock),
                  label: const Text("🔑 Change Password"),
                ),
                ElevatedButton.icon(
                  onPressed: _deleteAccount,
                  icon: const Icon(Icons.delete),
                  label: const Text("🗑 Delete Account"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text("🚪 Logout"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
