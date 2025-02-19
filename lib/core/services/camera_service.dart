import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraService {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  List<CameraDescription> _cameras = [];

  /// Initializes the camera
  Future<void> initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _cameraController = CameraController(
          _cameras.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        _isCameraInitialized = true;
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  /// Returns the camera preview widget
  Widget getCameraPreview() {
    if (_isCameraInitialized && _cameraController != null) {
      return AspectRatio(
        aspectRatio: _cameraController!.value.aspectRatio,
        child: CameraPreview(_cameraController!),
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  /// Disposes the camera
  void disposeCamera() {
    _cameraController?.dispose();
    _isCameraInitialized = false;
  }

  /// Returns the CameraController instance
  CameraController? getController() {
    return _cameraController;
  }

  /// Returns the camera initialization state
  bool isCameraReady() {
    return _isCameraInitialized;
  }
}
