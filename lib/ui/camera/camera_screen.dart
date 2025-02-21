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
  bool _isProcessing = false;
  bool _isCaptureCentered = true; // ✅ Tracks which button is in center
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

  Future<void> _captureAndProcess() async {
    if (_cameraController == null || !_isCameraInitialized || _isProcessing) {
      return;
    }

    if (!_isCaptureCentered) {
      // If capture button is on the right, bring it back to the center
      setState(() {
        _isCaptureCentered = true;
      });
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    await _captureService.captureAndProcessImage(
        context, _cameraController!, _isCameraInitialized);

    setState(() {
      _isProcessing = false;
    });
  }

  void _toggleMode() {
    setState(() {
      _isCaptureCentered = !_isCaptureCentered;
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

            /// **📌 Capture Button (Swaps with Audio Button)**
            Positioned(
              bottom: 50,
              left: _isCaptureCentered
                  ? MediaQuery.of(context).size.width * 0.5 - 28
                  : MediaQuery.of(context).size.width * 0.8,
              child: FloatingActionButton(
                heroTag: "capture",
                onPressed: _captureAndProcess,
                child: const Icon(Icons.camera_alt_outlined, size: 28),
              ),
            ),

            /// **📌 Voice Recording Button (Swaps with Capture Button)**
            Positioned(
              bottom: 50,
              left: _isCaptureCentered
                  ? MediaQuery.of(context).size.width * 0.8
                  : MediaQuery.of(context).size.width * 0.5 - 28,
              child: FloatingActionButton(
                heroTag: "voice_record",
                onPressed: _toggleMode,
                child: const Icon(Icons.mic, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
