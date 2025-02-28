import 'package:flutter/material.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child}); // ✅ Allow child

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Note Taker"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              debugPrint("🔹 Profile button clicked");
            },
          ),
        ],
      ),
      body: child, // ✅ Display the child screen dynamically
    );
  }
}
