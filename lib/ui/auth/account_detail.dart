import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dart_app/ui/home/home_screen.dart';
import 'package:dart_app/ui/auth/account_detail/widgets/change_email_dialog.dart';
import 'package:dart_app/ui/auth/account_detail/widgets/change_password_dialog.dart';
import 'package:dart_app/ui/auth/account_detail/widgets/delete_account_dialog.dart';
import 'package:dart_app/ui/auth/account_detail/widgets/verify_email_button.dart';

class AccountDetailScreen extends StatefulWidget {
  final User user;

  const AccountDetailScreen({super.key, required this.user});

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
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

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
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
              icon: const Icon(Icons.refresh),
              onPressed: _reloadUser,
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
                  VerifyEmailButton(
                    isVerifying: false,
                    onSendEmail: _reloadUser,
                    user: currentUser,
                  ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    _showSnackBar(
                        "ℹ️ Change Name feature coming soon!", Colors.blue);
                  },
                  icon: const Icon(Icons.person),
                  label: const Text("🔄 Change Name"),
                ),
                ElevatedButton.icon(
                  onPressed: () => showChangeEmailDialog(
                    context,
                    currentUser,
                    _reloadUser,
                    _showSnackBar,
                  ),
                  icon: const Icon(Icons.email),
                  label: const Text("📧 Change Email"),
                ),
                ElevatedButton.icon(
                  onPressed: () => showChangePasswordDialog(
                    context,
                    currentUser,
                    _showSnackBar,
                  ),
                  icon: const Icon(Icons.lock),
                  label: const Text("🔑 Change Password"),
                ),
                ElevatedButton.icon(
                  onPressed: () => showDeleteAccountDialog(
                    context,
                    currentUser,
                    _showSnackBar,
                  ),
                  icon: const Icon(Icons.delete),
                  label: const Text("🗑 Delete Account"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    }
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
