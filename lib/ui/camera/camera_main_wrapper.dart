import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dart_app/ui/saved/gallery_screen.dart';
import 'package:dart_app/ui/home/home_screen.dart';

import 'capture_preview_screen.dart';

/// 🎤 AUDIO SCREEN (Placeholder)
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

  void _onTapFocus(TapUpDetails details) {
    if (!_initialized || _controller == null) return;

    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    final Size screenSize = box.size;

    final double dx = localPosition.dx / screenSize.width;
    final double dy = localPosition.dy / screenSize.height;

    if (_controller!.value.isInitialized &&
        _controller!.value.focusPointSupported) {
      _controller!.setFocusPoint(Offset(dx, dy));
    }

    setState(() => _tapPosition = localPosition);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _tapPosition = null);
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
          if (_tapPosition != null)
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

/// 🎛 MAIN WRAPPER
class CameraMainWrapper extends StatefulWidget {
  const CameraMainWrapper({super.key});

  @override
  State<CameraMainWrapper> createState() => _CameraMainWrapperState();
}

class _CameraMainWrapperState extends State<CameraMainWrapper> {
  final GlobalKey<CameraScreenState> _cameraKey = GlobalKey();

  int _selectedIndex = 2;

  late final List<Widget> _screens = [
    const SizedBox(), // placeholder for home
    const SizedBox(), // placeholder for gallery
    CameraScreen(key: _cameraKey),
    const AudioScreen(),
  ];

  Future<void> _onItemTapped(int index) async {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const GalleryScreen()),
      );
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: _screens[_selectedIndex]),
          if (_selectedIndex == 2)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: Stack(
                  alignment: Alignment.center,
                  children: const [
                    HaloRing(),
                    CaptureButton(),
                  ],
                ),
              ),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[900]!.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _NavIcon(
                        icon: Icons.arrow_back_ios_new,
                        selected: false,
                        onTap: () => _onItemTapped(0),
                        color: Colors.white),
                    const SizedBox(width: 20),
                    _NavIcon(
                        icon: Icons.photo_library,
                        selected: false,
                        onTap: () => _onItemTapped(1),
                        color: Colors.white),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        if (_selectedIndex == 2) {
                          _cameraKey.currentState?._captureAndProcess();
                        } else {
                          _onItemTapped(2);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        child: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 26),
                      ),
                    ),
                    const SizedBox(width: 20),
                    _NavIcon(
                        icon: Icons.mic,
                        selected: _selectedIndex == 3,
                        onTap: () => _onItemTapped(3),
                        color: Colors.white),
                    const SizedBox(width: 20),
                    _NavIcon(
                        icon: Icons.share,
                        selected: false,
                        onTap: () {},
                        color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🔘 NAV ICON BUTTON
class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  const _NavIcon({
    required this.icon,
    required this.selected,
    required this.onTap,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        color: selected ? color : color.withOpacity(0.5),
        size: 26,
      ),
    );
  }
}

/// 📸 CAPTURE BUTTON (Transparent inner with white ring only)
class CaptureButton extends StatelessWidget {
  const CaptureButton({super.key});

  @override
  Widget build(BuildContext context) {
    final parent = context.findAncestorStateOfType<_CameraMainWrapperState>();
    return GestureDetector(
      onTap: () => parent?._cameraKey.currentState?._captureAndProcess(),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
        ),
      ),
    );
  }
}

/// 🌟 HALO EFFECT
class HaloRing extends StatelessWidget {
  const HaloRing({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [Color(0x33FF0000), Colors.transparent],
          center: Alignment.center,
          radius: 0.6,
        ),
      ),
    );
  }
}
