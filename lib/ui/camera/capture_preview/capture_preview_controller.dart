import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dart_app/core/services/gemini_service.dart';
import 'package:dart_app/core/utils/text_extraction_util.dart';

class CapturePreviewController extends ChangeNotifier {
  File? croppedFile;
  String extractedText = "";
  bool isProcessing = true;
  bool isSaved = false;
  String? lastSavedImagePath;
  final GeminiService geminiService = GeminiService();

  late File originalImage;

  void initialize(XFile imageFile) {
    originalImage = File(imageFile.path);
    _processImage(originalImage);
  }

  Future<void> _processImage(File imageFile) async {
    isProcessing = true;
    notifyListeners();

    final result = await TextExtractionUtil.extractText(imageFile);
    extractedText = result;
    isProcessing = false;
    notifyListeners();
  }

  File get currentImage => croppedFile ?? originalImage;

  Future<void> cropImage() async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: originalImage.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: false,
        ),
      ],
    );

    if (cropped != null) {
      croppedFile = File(cropped.path);
      isSaved = false;
      notifyListeners();
      await _processImage(croppedFile!);
    }
  }

  Future<void> saveFile(BuildContext context) async {
    final directory = await getApplicationDocumentsDirectory();
    final targetPath =
        '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final sourcePath = currentImage.path;

    if (sourcePath == lastSavedImagePath) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Already saved.")),
      );
      return;
    }

    await File(sourcePath).copy(targetPath);
    lastSavedImagePath = sourcePath;
    isSaved = true;

    final savedData = {
      "imagePath": targetPath,
      "text": extractedText,
      "timestamp": DateTime.now().toIso8601String(),
    };

    final textPath = '${directory.path}/saved_texts.json';
    List<Map<String, String>> savedFiles = [];
    if (File(textPath).existsSync()) {
      final content = await File(textPath).readAsString();
      if (content.isNotEmpty) {
        List<Map<String, dynamic>> rawData =
            List<Map<String, dynamic>>.from(json.decode(content));
        savedFiles = rawData.map((e) => e.cast<String, String>()).toList();
      }
    }

    savedFiles.add(savedData);
    await File(textPath).writeAsString(json.encode(savedFiles));

    notifyListeners();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ File Saved Successfully")),
    );
  }

  void copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: extractedText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("📋 Text Copied to Clipboard")),
    );
  }

  Future<void> summarizeText(BuildContext context) async {
    try {
      final summary = await geminiService.summarizeText(
        "Summarize and explain what the following content is about:\n\n$extractedText",
      );

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("📝 Summary"),
            content: Text(summary),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed to summarize: $e")),
        );
      }
    }
  }

  Future<bool> handleExitConfirmation(BuildContext context) async {
    if (isSaved) return true;

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Exit Without Saving?"),
        content: const Text("You haven't saved this capture. Exit anyway?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("No")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Yes")),
        ],
      ),
    );

    return shouldExit ?? false;
  }
}
