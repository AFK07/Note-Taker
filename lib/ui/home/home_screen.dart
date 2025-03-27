import 'package:flutter/material.dart';
import 'package:dart_app/ui/camera/camera_screen.dart';
import 'package:dart_app/ui/saved/gallery_screen.dart';
import 'package:dart_app/ui/auth/profile_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dart_app/firebase_options.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Note Taker"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
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
                  MaterialPageRoute(builder: (context) => const CameraScreen()),
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
                  MaterialPageRoute(
                      builder: (context) => const GalleryScreen()),
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
                  debugPrint("✅ Firebase Initialized: ${result.name}");
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("✅ Firebase is working!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
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
    );
  }
}
