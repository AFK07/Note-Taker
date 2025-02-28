import 'package:flutter/material.dart';
import 'package:dart_app/ui/camera/camera_screen.dart'; // Ensure correct import path
import 'package:dart_app/ui/saved/saved_files_screen.dart';
import 'package:dart_app/ui/saved/gallery_screen.dart';

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
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const CameraScreen(), // Ensure CameraScreen is recognized
                  ),
                );
              },
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text("Open Camera"),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SavedFilesScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.folder),
              label: const Text("Saved Files"),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GalleryScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.photo_library),
              label: const Text("Gallery"),
            ),
          ],
        ),
      ),
    );
  }
}
