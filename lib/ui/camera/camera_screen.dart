import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:dart_app/core/services/capture_service.dart';
import 'package:dart_app/ui/saved/gallery_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isProcessing = false; // ✅ Prevent multiple captures
  final CaptureService _captureService = CaptureService();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  /// **Initializes the Camera**
  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint("❌ No cameras found!");
        return;
      }

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
      debugPrint('❌ Error initializing camera: $e');
    }
  }

  /// **Handles Image Capture & Processing**
  Future<void> _captureAndProcess() async {
    if (_cameraController == null || !_isCameraInitialized || _isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true; // ✅ Prevents multiple captures
    });

    await _captureService.captureAndProcessImage(
        context, _cameraController!, _isCameraInitialized);

    setState(() {
      _isProcessing = false;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // ✅ Prevents elements from overlapping status bar
        child: Stack(
          children: [
            Positioned.fill(
              child: _isCameraInitialized
                  ? CameraPreview(_cameraController!)
                  : const Center(child: CircularProgressIndicator()),
            ),

            /// **📌 Gallery Button**
            Positioned(
              bottom: 50,
              left: MediaQuery.of(context).size.width * 0.2,
              child: FloatingActionButton(
                heroTag: "gallery", // ✅ Prevent Hero Tag Conflicts
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GalleryScreen(),
                    ),
                  );
                },
                child: const Icon(Icons.photo_library, size: 28),
              ),
            ),

            /// **📌 Camera Capture Button (Centered)**
            Positioned(
              bottom: 50,
              left: MediaQuery.of(context).size.width * 0.5 - 28,
              child: FloatingActionButton(
                heroTag: "capture",
                onPressed: _isProcessing
                    ? null
                    : _captureAndProcess, // ✅ Prevent multiple taps
                child: const Icon(Icons.camera_alt, size: 28),
              ),
            ),

            /// **📌 Voice Recording Button**
            Positioned(
              bottom: 50,
              right: MediaQuery.of(context).size.width * 0.2,
              child: FloatingActionButton(
                heroTag: "voice_record",
                onPressed: () {
                  // TODO: Implement voice recording functionality
                },
                child: const Icon(Icons.mic, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
