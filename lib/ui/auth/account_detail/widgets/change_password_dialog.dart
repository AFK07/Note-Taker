import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> showChangePasswordDialog(
  BuildContext context,
  User user,
  void Function(String message, Color color) showSnackBar,
) async {
  final currentController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();

  bool obscureCurrent = true;
  bool obscureNew = true;
  bool obscureConfirm = true;

  await showDialog(
    context: context,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Change Password"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                TextField(
                  controller: currentController,
                  obscureText: obscureCurrent,
                  decoration: InputDecoration(
                    labelText: "Current Password",
                    suffixIcon: IconButton(
                      icon: Icon(obscureCurrent
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () =>
                          setState(() => obscureCurrent = !obscureCurrent),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: newController,
                  obscureText: obscureNew,
                  decoration: InputDecoration(
                    labelText: "New Password",
                    suffixIcon: IconButton(
                      icon: Icon(
                          obscureNew ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => obscureNew = !obscureNew),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: confirmController,
                  obscureText: obscureConfirm,
                  decoration: InputDecoration(
                    labelText: "Confirm New Password",
                    suffixIcon: IconButton(
                      icon: Icon(obscureConfirm
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () =>
                          setState(() => obscureConfirm = !obscureConfirm),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final current = currentController.text.trim();
                final newPass = newController.text.trim();
                final confirm = confirmController.text.trim();

                Navigator.pop(context);

                if (newPass.isEmpty || confirm.isEmpty || current.isEmpty) {
                  showSnackBar("❌ All fields are required", Colors.red);
                  return;
                }

                if (newPass.length < 6) {
                  showSnackBar(
                      "❌ Password must be at least 6 characters", Colors.red);
                  return;
                }

                if (newPass != confirm) {
                  showSnackBar("❌ New passwords do not match", Colors.red);
                  return;
                }

                try {
                  final cred = EmailAuthProvider.credential(
                    email: user.email!.trim(),
                    password: current,
                  );
                  await user.reauthenticateWithCredential(cred);
                  await user.updatePassword(newPass);
                  showSnackBar("✅ Password updated", Colors.green);
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'wrong-password') {
                    showSnackBar("❌ Incorrect current password", Colors.red);
                  } else if (e.code == 'requires-recent-login') {
                    showSnackBar("❌ Session expired. Please sign in again.",
                        Colors.orange);
                  } else {
                    showSnackBar("❌ Firebase error: ${e.message}", Colors.red);
                  }
                } catch (e) {
                  showSnackBar("❌ Error: $e", Colors.red);
                }
              },
              child: const Text("Submit"),
            ),
          ],
        ),
      );
    },
  );
}
