import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerifyEmailButton extends StatefulWidget {
  final User user;
  final bool isVerifying;
  final VoidCallback onSendEmail;

  const VerifyEmailButton({
    super.key,
    required this.user,
    required this.isVerifying,
    required this.onSendEmail,
  });

  @override
  State<VerifyEmailButton> createState() => _VerifyEmailButtonState();
}

class _VerifyEmailButtonState extends State<VerifyEmailButton> {
  bool isSending = false;

  Future<void> _sendVerification() async {
    try {
      setState(() => isSending = true);
      await widget.user.sendEmailVerification();
      widget.onSendEmail();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("📨 Verification email sent!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to send: $e")),
      );
    } finally {
      setState(() => isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isSending ? null : _sendVerification,
      icon: const Icon(Icons.mark_email_unread),
      label: Text(isSending ? "Sending..." : "Send Verification Email"),
    );
  }
}
