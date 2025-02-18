import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';

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

  /// Captures an image and returns the file
  Future<File?> captureImage() async {
    if (_isCameraInitialized && _cameraController != null) {
      try {
        final XFile imageFile = await _cameraController!.takePicture();
        return File(imageFile.path);
      } catch (e) {
        debugPrint('Error capturing image: $e');
      }
    }
    return null;
  }

  /// Disposes the camera controller
  void disposeCamera() {
    _cameraController?.dispose();
    _isCameraInitialized = false;
  }

  /// Returns the camera preview widget
  Widget getCameraPreview() {
    if (_isCameraInitialized && _cameraController != null) {
      return AspectRatio(
        aspectRatio:
            _cameraController!.value.aspectRatio, // Dynamic aspect ratio
        child: CameraPreview(_cameraController!),
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }
}
