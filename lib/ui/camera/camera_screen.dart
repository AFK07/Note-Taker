import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'capture_preview_screen.dart';

/// 📁 GALLERY SCREEN
class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CapturePreviewScreen(imageFile: pickedFile),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => _pickImage(context),
        icon: const Icon(Icons.photo_library),
        label: const Text("Pick from Gallery"),
      ),
    );
  }
}

/// 🎤 AUDIO SCREEN
class AudioScreen extends StatelessWidget {
  const AudioScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "🎤 Audio Screen (Coming Soon)",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
    );
  }
}

/// 📷 CAMERA SCREEN
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});
  @override
  State<CameraScreen> createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  static CameraScreenState? of(BuildContext context) =>
      context.findAncestorStateOfType<CameraScreenState>();

  CameraController? _controller;
  bool _initialized = false;
  Offset? _tapPosition;
  bool _showFocusCircle = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(cameras.first, ResolutionPreset.high);
    await _controller?.initialize();
    if (mounted) setState(() => _initialized = true);
  }

  Future<void> _captureAndProcess() async {
    if (!_initialized || _controller == null) return;
    try {
      final XFile image = await _controller!.takePicture();
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CapturePreviewScreen(imageFile: image),
        ),
      );
    } catch (e) {
      debugPrint("❌ Capture failed: $e");
    }
  }

  void _onTapFocus(TapUpDetails details) async {
    if (!_initialized || !_controller!.value.isInitialized) return;

    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(details.globalPosition);
    final Size size = box.size;

    final double dx = localPosition.dx / size.width;
    final double dy = localPosition.dy / size.height;

    if (_controller!.value.focusPointSupported) {
      await _controller!.setFocusPoint(Offset(dx, dy));
    }

    setState(() {
      _tapPosition = localPosition;
      _showFocusCircle = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _showFocusCircle = false);
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: _onTapFocus,
      child: Stack(
        children: [
          Positioned.fill(
            child: _initialized
                ? CameraPreview(_controller!)
                : const Center(child: CircularProgressIndicator()),
          ),
          if (_showFocusCircle && _tapPosition != null)
            Positioned(
              left: _tapPosition!.dx - 30,
              top: _tapPosition!.dy - 30,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.yellowAccent, width: 2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
