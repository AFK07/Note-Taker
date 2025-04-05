import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
// import 'package:dart_app/core/services/capture_service.dart';
import 'package:dart_app/ui/saved/gallery_screen.dart';
import 'package:dart_app/ui/audio/audio_screen.dart';
import 'package:dart_app/ui/camera/capture_preview_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isCameraCentered = true; // ✅ Tracks which button is centered
  // final CaptureService _captureService = CaptureService();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  /// **📌 Initializes Camera**
  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint("❌ No cameras found!");
        return;
      }

      _cameraController = CameraController(
        cameras.first,
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

  /// **📌 Toggles Between Camera & Audio Mode**
  void _swapButtons() {
    setState(() {
      _isCameraCentered = !_isCameraCentered;
    });
  }

  /// **📌 Capture & Process Image**
  Future<void> _captureAndProcess() async {
    if (_cameraController == null || !_isCameraInitialized) return;
    try {
      final XFile imageFile = await _cameraController!.takePicture();
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CapturePreviewScreen(imageFile: imageFile),
        ),
      );
    } catch (e) {
      debugPrint("❌ Error capturing image: $e");
    }
  }

  /// **📌 Returns Active Screen Based on Centered Button**
  Widget _getActiveScreen() {
    return _isCameraCentered
        ? (_isCameraInitialized
            ? CameraPreview(_cameraController!)
            : const Center(child: CircularProgressIndicator()))
        : const AudioScreen();
  }

  /// **📌 Floating Action Buttons for Controls**
  Widget _buildFloatingButtons(BuildContext context) {
    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          /// **📌 Gallery Button**
          FloatingActionButton(
            heroTag: "gallery",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GalleryScreen()),
              );
            },
            child: const Icon(Icons.photo_library, size: 28),
          ),

          /// **📌 Dynamic Center Button**
          FloatingActionButton(
            heroTag: "center_button",
            onPressed: _isCameraCentered ? _captureAndProcess : _swapButtons,
            child: Icon(
              _isCameraCentered ? Icons.camera_alt_outlined : Icons.mic,
              size: 28,
            ),
          ),

          /// **📌 Dynamic Right Button**
          FloatingActionButton(
            heroTag: "right_button",
            onPressed: _swapButtons,
            child: Icon(
              _isCameraCentered ? Icons.mic : Icons.camera_alt_outlined,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: _getActiveScreen()), // ✅ Camera or Audio UI
        _buildFloatingButtons(context), // ✅ Floating Controls
      ],
    );
  }
}
