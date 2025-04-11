import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dart_app/ui/home/home_screen.dart';
import 'package:dart_app/ui/auth/account_detail/widgets/change_email_dialog.dart';
import 'package:dart_app/ui/auth/account_detail/widgets/change_password_dialog.dart';
import 'package:dart_app/ui/auth/account_detail/widgets/delete_account_dialog.dart';

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
    if (!mounted) return;
    setState(() {
      currentUser = FirebaseAuth.instance.currentUser!;
    });
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isVerified = currentUser.emailVerified;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Disable default back button
          title: const Text('Account Settings'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Ensure the back button takes to the HomeScreen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _reloadUser,
              tooltip: "Refresh",
            )
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Icon(Icons.account_circle, size: 100, color: Colors.grey),
            const SizedBox(height: 20),
            ListTile(
              title: const Text("Display Name"),
              subtitle: Text(
                "Coming soon...",
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: const Icon(Icons.edit),
              onTap: () {
                _showSnackBar(
                    "ℹ️ Change Name feature coming soon!", Colors.blue);
              },
            ),
            const Divider(),
            ListTile(
              title: const Text("Email"),
              subtitle: Text(
                currentUser.email ?? '',
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: const Icon(Icons.edit),
              onTap: () => showChangeEmailDialog(
                context,
                currentUser,
                _reloadUser,
                _showSnackBar,
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text("Password"),
              subtitle: const Text(
                "●●●●●●●●",
                style: TextStyle(color: Colors.grey),
              ),
              trailing: const Icon(Icons.edit),
              onTap: () => showChangePasswordDialog(
                context,
                currentUser,
                _showSnackBar,
              ),
            ),
            const Divider(),
            ListTile(
              title: Text(
                  isVerified ? "✅ Email Verified" : "⚠ Email Not Verified"),
              subtitle: Text(
                isVerified
                    ? "Your email is verified"
                    : "Tap to verify your email",
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing:
                  !isVerified ? const Icon(Icons.verified_user_outlined) : null,
              onTap: !isVerified
                  ? () async {
                      try {
                        await currentUser.sendEmailVerification();
                        if (mounted) {
                          _showSnackBar(
                              "📨 Verification email sent!", Colors.green);
                        }
                      } catch (e) {
                        if (mounted) {
                          _showSnackBar(
                              "❌ Failed to send verification email: $e",
                              Colors.red);
                        }
                      }
                    }
                  : null,
            ),
            const Divider(),
            ListTile(
              title: const Text("Delete Account"),
              trailing: const Icon(Icons.delete, color: Colors.red),
              onTap: () => showDeleteAccountDialog(
                context,
                currentUser,
                _showSnackBar,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (!mounted) return;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text("🚪 Logout"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
