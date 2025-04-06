import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:dart_app/firebase_options.dart';
import 'package:dart_app/ui/camera/camera_screen.dart';
import 'package:dart_app/ui/saved/gallery_screen.dart';
import 'package:dart_app/ui/auth/profile_screen.dart';
import 'package:dart_app/ui/auth/account_detail.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 🚫 Disable system back navigation
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // 🚫 Remove back arrow
          title: const Text("Smart Note Taker"),
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              tooltip: "Profile / Account",
              onPressed: () {
                final user = FirebaseAuth.instance.currentUser;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => user != null
                        ? AccountDetailScreen(user: user)
                        : const ProfileScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text("Open Camera"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CameraScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.photo_library),
                label: const Text("Gallery"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GalleryScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.cloud_done),
                label: const Text("Test Firebase"),
                onPressed: () async {
                  try {
                    final result = await Firebase.initializeApp(
                      options: DefaultFirebaseOptions.currentPlatform,
                    );
                    if (!context.mounted)
                      return; // ✅ Avoid using context if widget is unmounted
                    debugPrint("✅ Firebase Initialized: ${result.name}");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("✅ Firebase is working!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    debugPrint("❌ Firebase Init Error: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("❌ Firebase Error: $e"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
