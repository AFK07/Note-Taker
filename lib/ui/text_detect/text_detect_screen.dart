import 'dart:io';
import 'dart:convert'; // Add this import for JSON encoding/decoding
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import for Clipboard
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart'; // For text recognition
import 'package:path_provider/path_provider.dart'; // For file handling
import 'package:dart_app/ui/saved/full_image_screen.dart'; // For navigating to FullImageScreen

class TextDetectScreen extends StatefulWidget {
  final File image;

  const TextDetectScreen({super.key, required this.image});

  @override
  State<TextDetectScreen> createState() => _TextDetectScreenState();
}

class _TextDetectScreenState extends State<TextDetectScreen> {
  String extractedText = "";
  bool isProcessing = true;

  @override
  void initState() {
    super.initState();
    _processImage(widget.image);
  }

  /// **Processes the image to extract text**
  Future<void> _processImage(File image) async {
    final textRecognizer = TextRecognizer();
    final inputImage = InputImage.fromFile(image);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    if (!mounted) return;
    setState(() {
      extractedText = recognizedText.text;
      isProcessing = false;
    });
  }

  /// **Saves the extracted text and image**
  Future<void> _saveFile() async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String imagePath =
          '${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await widget.image.copy(imagePath);

      final String textPath = '${appDir.path}/saved_texts.json';
      List<Map<String, dynamic>> savedFiles = [];

      if (File(textPath).existsSync()) {
        String content = await File(textPath).readAsString();
        if (content.isNotEmpty) {
          savedFiles = List<Map<String, dynamic>>.from(json.decode(content));
        }
      }

      savedFiles.add({
        "imagePath": imagePath,
        "text": extractedText,
        "timestamp": DateTime.now().toIso8601String(),
      });

      await File(textPath).writeAsString(json.encode(savedFiles));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File Saved Successfully")),
      );

      Navigator.pop(context, true); // Return to the previous screen
    } catch (e) {
      debugPrint("❌ Save Error: $e");
    }
  }

  /// **Copies the extracted text to the clipboard**
  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: extractedText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("📋 Text Copied to Clipboard")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Text Detection"),
        actions: [
          IconButton(
            onPressed: _copyToClipboard,
            icon: const Icon(Icons.copy),
          ),
          IconButton(
            onPressed: _saveFile,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Image.file(widget.image),
          ),
          if (isProcessing) const Center(child: CircularProgressIndicator()),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(
                extractedText.isNotEmpty ? extractedText : "No text found",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
