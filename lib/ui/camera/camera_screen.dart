import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:dart_app/core/services/capture_service.dart';
import 'package:dart_app/ui/saved/gallery_screen.dart';
import 'package:dart_app/ui/audio/audio_screen.dart'; // ✅ Uses AudioScreen for recording

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isCaptureCentered = true; // ✅ Tracks which button is in center
  bool _isAudioMode = false; // ✅ Tracks if in audio mode
  final CaptureService _captureService = CaptureService();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

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

  void _toggleMode() {
    setState(() {
      _isCaptureCentered = !_isCaptureCentered;
      _isAudioMode = !_isAudioMode;
    });
  }

  Future<void> _captureAndProcess() async {
    if (_cameraController == null || !_isCameraInitialized) {
      return;
    }
    // Placeholder action for capture function
    debugPrint("📸 Image captured!");
  }

  Widget _getActiveScreen() {
    return _isCaptureCentered
        ? (_isCameraInitialized
            ? CameraPreview(_cameraController!)
            : const Center(child: CircularProgressIndicator()))
        : const AudioScreen(); // ✅ Uses AudioScreen for audio mode
  }

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
          Positioned.fill(child: _getActiveScreen()),

          /// **📌 Gallery Button (Shifted to the Left for Balance)**
          Positioned(
            bottom: 30,
            left: MediaQuery.of(context).size.width * 0.2 - 40,
            child: FloatingActionButton(
              heroTag: "gallery",
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

          /// **📌 Capture Button (Switches Back to Center When Clicked)**
          Positioned(
            bottom: 30,
            left: _isCaptureCentered
                ? MediaQuery.of(context).size.width * 0.5 - 28
                : MediaQuery.of(context).size.width * 0.8,
            child: FloatingActionButton(
              heroTag: "capture",
              onPressed: _isCaptureCentered ? _captureAndProcess : _toggleMode,
              child: const Icon(Icons.camera_alt_outlined, size: 28),
            ),
          ),

          /// **📌 Voice Recording Button (Switches Back to Center When Clicked)**
          Positioned(
            bottom: 30,
            left: _isCaptureCentered
                ? MediaQuery.of(context).size.width * 0.8
                : MediaQuery.of(context).size.width * 0.5 - 28,
            child: FloatingActionButton(
              heroTag: "voice_record",
              onPressed: _isCaptureCentered
                  ? _toggleMode
                  : () => setState(() => _isCaptureCentered = true),
              child: const Icon(Icons.mic, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}
