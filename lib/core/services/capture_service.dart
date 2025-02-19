import 'dart:io';
import 'dart:convert'; // ✅ Fix: Import JSON handling
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dart_app/ui/text_detect/image_preview.dart';
import 'package:dart_app/ui/text_detect/text_detect_screen.dart';

class CaptureService {
  /// **Handles Capturing & Processing Image**
  Future<void> captureAndProcessImage(BuildContext context,
      CameraController? cameraController, bool isCameraInitialized) async {
    if (cameraController == null || !isCameraInitialized) {
      debugPrint("❌ Camera not initialized.");
      return;
    }

    try {
      final XFile imageFile = await cameraController.takePicture();
      final File file = File(imageFile.path);

      if (!context.mounted) return;
      final File? processedImage = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePreviewScreen(image: file),
        ),
      );

      if (!context.mounted) return;
      if (processedImage != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TextDetectScreen(image: processedImage),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error capturing image: $e');
    }
  }

  /// **Saves the captured image & extracted text**
  Future<void> saveFile(File image, String extractedText) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String imagePath =
          '${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.png';
      await image.copy(imagePath);

      final String textPath = '${appDir.path}/saved_texts.json';
      List<Map<String, dynamic>> savedFiles = [];

      if (File(textPath).existsSync()) {
        String content = await File(textPath).readAsString();

        try {
          savedFiles = List<Map<String, dynamic>>.from(json.decode(content));
        } catch (e) {
          debugPrint("❌ JSON Parsing Error: $e");
          savedFiles = []; // Reset in case of corruption
        }
      }

      // ✅ Add new entry with timestamp
      savedFiles.add({
        "imagePath": imagePath,
        "text": extractedText,
        "timestamp": DateTime.now().toIso8601String(),
      });

      await File(textPath).writeAsString(json.encode(savedFiles));

      debugPrint("✅ Image & text saved successfully!");
    } catch (e) {
      debugPrint("❌ Save Error: $e");
    }
  }

  /// **Loads Saved Files**
  Future<List<Map<String, dynamic>>> loadSavedFiles() async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String textPath = '${appDir.path}/saved_texts.json';

      if (File(textPath).existsSync()) {
        String content = await File(textPath).readAsString();

        try {
          return List<Map<String, dynamic>>.from(json.decode(content));
        } catch (e) {
          debugPrint("❌ JSON Parsing Error: $e");
          return [];
        }
      }
      return [];
    } catch (e) {
      debugPrint("❌ Error loading saved files: $e");
      return [];
    }
  }
}
