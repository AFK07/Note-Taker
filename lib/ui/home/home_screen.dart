import 'package:flutter/material.dart';
import 'package:dart_app/ui/camera/camera_screen.dart';
import 'package:dart_app/ui/saved/saved_files_screen.dart';
import 'package:dart_app/ui/saved/gallery_screen.dart'; // ✅ Import Gallery Screen

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CameraScreen(),
                  ),
                );
              },
              child: const Text("Open Camera"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SavedFilesScreen(),
                  ),
                );
              },
              child: const Text("Saved Files"), // ✅ Opens SavedFilesScreen
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GalleryScreen(),
                  ),
                );
              },
              child: const Text("Gallery"), // ✅ Opens GalleryScreen
            ),
          ],
        ),
      ),
    );
  }
}
