import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';

import 'package:dart_app/firebase_options.dart';
import 'package:dart_app/ui/camera/camera_main_wrapper.dart' as cam;
import 'package:dart_app/ui/saved/gallery_screen.dart';
import 'package:dart_app/ui/auth/profile_screen.dart';
import 'package:dart_app/ui/auth/account_detail.dart';
import 'package:dart_app/ui/camera/capture_preview_screen.dart'; // Import for capture preview

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
                  MaterialPageRoute(
                    builder: (_) => const cam.CameraMainWrapper(),
                  ),
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
                    builder: (_) => const GalleryScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text("Upload Image"),
              onPressed: () async {
                final ImagePicker _picker = ImagePicker();
                final XFile? pickedImage = await _picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 50,
                );

                if (pickedImage != null) {
                  final String path = pickedImage.path;
                  if (!context.mounted) return;
                  // Navigate directly to CapturePreviewScreen after image selection
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CapturePreviewScreen(imageFile: pickedImage),
                    ),
                  );
                }
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
                  if (!context.mounted) return;

                  debugPrint("✅ Firebase Initialized: \${result.name}");
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("✅ Firebase is working!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  debugPrint("❌ Firebase Init Error: \$e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("❌ Firebase Error: \$e"),
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
