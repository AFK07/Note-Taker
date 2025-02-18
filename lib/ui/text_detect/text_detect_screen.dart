import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter/services.dart'; // Clipboard
import 'package:path_provider/path_provider.dart'; // File Storage
import 'dart:convert'; // JSON Encoding

class TextDetectScreen extends StatefulWidget {
  final File image;
  const TextDetectScreen({super.key, required this.image});

  @override
  State<TextDetectScreen> createState() => _TextDetectScreenState();
}

class _TextDetectScreenState extends State<TextDetectScreen> {
  String detectedText = "Processing..."; // Default text

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  /// Detects text from the captured image
  Future<void> _processImage() async {
    final InputImage inputImage = InputImage.fromFile(widget.image);
    final textRecognizer = GoogleMlKit.vision.textRecognizer();

    try {
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      setState(() {
        detectedText = recognizedText.text.isNotEmpty
            ? recognizedText.text
            : "No text detected.";
      });
    } catch (e) {
      setState(() {
        detectedText = "Error processing image.";
      });
      debugPrint("Text Recognition Error: $e");
    } finally {
      textRecognizer.close();
    }
  }

  /// Copies text to clipboard
  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: detectedText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Copied to clipboard!")),
    );
  }

  /// Saves the image and text
  Future<void> _saveFile() async {
    try {
      // Get app storage directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String imagePath =
          '${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String textPath = '${appDir.path}/saved_texts.json';

      // Save Image
      await widget.image.copy(imagePath);

      // Save Text in JSON
      List<Map<String, String>> savedData = [];
      if (File(textPath).existsSync()) {
        String content = await File(textPath).readAsString();
        savedData = List<Map<String, String>>.from(json.decode(content));
      }

      savedData.add({"imagePath": imagePath, "text": detectedText});
      await File(textPath).writeAsString(json.encode(savedData));

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saved Successfully!")),
      );
    } catch (e) {
      debugPrint("Save Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detected Text")),
      body: Column(
        children: [
          Expanded(child: Image.file(widget.image, fit: BoxFit.cover)),

          // Detected Text Display with Copy & Save Button
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Extracted Text:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                // Copyable Text Field
                SelectableText(
                  detectedText,
                  style: const TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 15),

                // Button Row (Copy & Save)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _copyToClipboard,
                      icon: const Icon(Icons.copy),
                      label: const Text("Copy Text"),
                    ),
                    ElevatedButton.icon(
                      onPressed: _saveFile,
                      icon: const Icon(Icons.save),
                      label: const Text("Save"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
