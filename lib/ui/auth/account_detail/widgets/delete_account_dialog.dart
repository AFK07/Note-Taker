import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dart_app/ui/home/home_screen.dart';

Future<void> showDeleteAccountDialog(
  BuildContext context,
  User user,
  void Function(String message, Color color) showSnackBar,
) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Confirm Delete"),
      content: const Text("Are you sure you want to delete your account?"),
      actions: [
        TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context, false)),
        TextButton(
            child: const Text("Delete"),
            onPressed: () => Navigator.pop(context, true)),
      ],
    ),
  );

  if (confirm == true) {
    try {
      await user.delete();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
      showSnackBar("🗑 Account deleted", Colors.red);
    } catch (e) {
      showSnackBar("❌ Error: $e", Colors.red);
    }
  }
}
