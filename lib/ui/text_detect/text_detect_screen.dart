import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
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
  String detectedText = "Processing...";
  bool isProcessing = true;

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  /// **Extracts text from the image and formats it**
  Future<void> _processImage() async {
    final InputImage inputImage = InputImage.fromFile(widget.image);
    final textRecognizer = TextRecognizer();

    try {
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      setState(() {
        detectedText = _formatText(recognizedText);
        isProcessing = false;
      });
    } catch (e) {
      setState(() {
        detectedText = "Error processing image.";
        isProcessing = false;
      });
      debugPrint("❌ Text Recognition Error: $e");
    } finally {
      textRecognizer.close();
    }
  }

  /// **Formats detected text with paragraphs, bullet points, and numbered lists**
  String _formatText(RecognizedText recognizedText) {
    StringBuffer formattedText = StringBuffer();

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        String text = line.text.trim();

        // Detect bullet points or numbered lists
        if (RegExp(r'^[•\-]\s').hasMatch(text)) {
          formattedText.writeln(text);
        } else if (RegExp(r'^\d+\.\s').hasMatch(text)) {
          formattedText.writeln(text);
        } else {
          formattedText.writeln("\n$text"); // Preserve paragraph spacing
        }
      }
    }
    return formattedText.toString().trim();
  }

  /// **Copies text to clipboard**
  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: detectedText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("📋 Copied to clipboard!")),
    );
  }

  /// **Saves the image and extracted text to local storage**
  Future<void> _saveFile() async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String imagePath =
          '${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String textPath = '${appDir.path}/saved_texts.json';

      await widget.image.copy(imagePath);

      List<Map<String, String>> savedData = [];
      if (File(textPath).existsSync()) {
        String content = await File(textPath).readAsString();
        savedData = List<Map<String, String>>.from(json.decode(content));
      }

      savedData.add({"imagePath": imagePath, "text": detectedText});
      await File(textPath).writeAsString(json.encode(savedData));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Saved Successfully!")),
      );
    } catch (e) {
      debugPrint("❌ Save Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to save.")),
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
                  style: const TextStyle(fontSize: 16, height: 1.5),
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
