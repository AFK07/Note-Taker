import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:dart_app/ui/text_detect/image_preview.dart';
import 'package:dart_app/ui/text_detect/text_detect_screen.dart';
import 'package:dart_app/ui/saved/saved_files_screen.dart'; // ✅ Import Saved Files Screen (Gallery)

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  /// Initializes the Camera
  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.first;

      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  /// Captures an Image and Navigates to the Preview Screen
  Future<void> _captureAndProcessImage() async {
    if (_cameraController == null || !_isCameraInitialized) return;

    try {
      final XFile imageFile = await _cameraController!.takePicture();
      final File file = File(imageFile.path);

      if (!mounted) return;
      final File? processedImage = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePreviewScreen(image: file),
        ),
      );

      if (!mounted) return;
      if (processedImage != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TextDetectScreen(image: processedImage),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error capturing image: $e');
    }
  }

  /// Disposes the Camera Controller
  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: _isCameraInitialized
                ? CameraPreview(_cameraController!)
                : const Center(child: CircularProgressIndicator()),
          ),

          /// ✅ Capture & Gallery Buttons
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// ✅ Gallery Button (Opens Saved Files)
                FloatingActionButton(
                  heroTag: "gallery",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SavedFilesScreen(),
                      ),
                    );
                  },
                  child: const Icon(Icons.photo_library, size: 28),
                ),

                /// ✅ Capture Button (Takes Picture)
                FloatingActionButton(
                  heroTag: "capture",
                  onPressed: _captureAndProcessImage,
                  child: const Icon(Icons.camera_alt, size: 28),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
