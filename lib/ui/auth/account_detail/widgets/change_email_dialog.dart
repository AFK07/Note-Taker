import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> showChangeEmailDialog(
  BuildContext context,
  User user,
  Future<void> Function() reloadUser,
  void Function(String message, Color color) showSnackBar,
) async {
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
            Navigator.pop(context);
            try {
              final cred = EmailAuthProvider.credential(
                email: user.email!,
                password: passwordController.text.trim(),
              );
              await user.reauthenticateWithCredential(cred);
              await user.updateEmail(emailController.text.trim());
              await reloadUser();
              showSnackBar("✅ Email updated", Colors.green);
            } catch (e) {
              showSnackBar("❌ Error: $e", Colors.red);
            }
          },
          child: const Text("Submit"),
        ),
      ],
    ),
  );
}
