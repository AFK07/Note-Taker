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

  String currentError = '';
  String newError = '';
  String confirmError = '';
  bool isCurrentPasswordCorrect = false;

  void validateInputs(StateSetter setState) {
    final current = currentController.text.trim();
    final newPass = newController.text.trim();
    final confirm = confirmController.text.trim();

    // Reset errors
    currentError = '';
    newError = '';
    confirmError = '';

    if (current.isEmpty) {
      currentError = 'Required';
    }

    if (newPass.isEmpty) {
      newError = 'Required';
    } else if (newPass.length < 6) {
      newError = 'Min 6 characters';
    } else if (current == newPass) {
      newError = 'New password must be different';
    }

    if (confirm.isEmpty) {
      confirmError = 'Required';
    } else if (newPass != confirm) {
      confirmError = 'Passwords do not match';
    }

    setState(() {});
  }

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setState) {
          final isValid = isCurrentPasswordCorrect &&
              currentError.isEmpty &&
              newError.isEmpty &&
              confirmError.isEmpty &&
              newController.text.trim().length >= 6 &&
              newController.text.trim() != currentController.text.trim() &&
              newController.text.trim() == confirmController.text.trim();

          return AlertDialog(
            title: const Text("Change Password"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentController,
                    obscureText: obscureCurrent,
                    decoration: InputDecoration(
                      labelText: "Current Password",
                      errorText: currentError.isNotEmpty ? currentError : null,
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureCurrent
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () =>
                            setState(() => obscureCurrent = !obscureCurrent),
                      ),
                    ),
                    onChanged: (_) => validateInputs(setState),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: newController,
                    obscureText: obscureNew,
                    decoration: InputDecoration(
                      labelText: "New Password",
                      errorText: newError.isNotEmpty ? newError : null,
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureNew ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () =>
                            setState(() => obscureNew = !obscureNew),
                      ),
                    ),
                    onChanged: (_) => validateInputs(setState),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: confirmController,
                    obscureText: obscureConfirm,
                    decoration: InputDecoration(
                      labelText: "Confirm New Password",
                      errorText: confirmError.isNotEmpty ? confirmError : null,
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureConfirm
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () =>
                            setState(() => obscureConfirm = !obscureConfirm),
                      ),
                    ),
                    onChanged: (_) => validateInputs(setState),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: isValid
                    ? () async {
                        try {
                          final cred = EmailAuthProvider.credential(
                            email: user.email!,
                            password: currentController.text.trim(),
                          );
                          await user.reauthenticateWithCredential(cred);
                          await user.updatePassword(newController.text.trim());

                          if (!context.mounted) return;
                          Navigator.pop(context);
                          showSnackBar("✅ Password updated", Colors.green);
                        } on FirebaseAuthException catch (e) {
                          setState(() {
                            isCurrentPasswordCorrect = false;
                            if (e.code == 'wrong-password') {
                              currentError = 'Incorrect password';
                            } else {
                              currentError =
                                  e.message ?? 'Unexpected error occurred';
                            }
                          });
                        }
                      }
                    : null,
                style: TextButton.styleFrom(
                  foregroundColor: isValid ? null : Colors.grey,
                ),
                child: const Text("Submit"),
              ),
            ],
          );
        },
      );
    },
  );
}
