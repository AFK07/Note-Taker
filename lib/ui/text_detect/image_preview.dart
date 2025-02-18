import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class ImagePreviewScreen extends StatefulWidget {
  final File image;

  const ImagePreviewScreen({super.key, required this.image});

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  late File _image;
  String _extractedText = "";

  @override
  void initState() {
    super.initState();
    _image = widget.image;
    _detectText(); // ✅ Auto-detect text when preview loads
  }

  /// **Crops the Captured Image**
  Future<void> _cropImage() async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: _image.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: "Crop Image",
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: "Crop Image",
          aspectRatioLockEnabled: false,
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        _image = File(croppedFile.path);
      });
      _detectText(); // ✅ Detect text again after cropping
    }
  }

  /// **Detects Text from Image**
  Future<void> _detectText() async {
    try {
      final textRecognizer = TextRecognizer();
      final inputImage = InputImage.fromFile(_image);
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      setState(() {
        _extractedText = recognizedText.text;
      });
    } catch (e) {
      debugPrint("Text Detection Error: $e");
    }
  }

  /// **Copies Detected Text**
  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _extractedText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Copied to clipboard!")),
    );
  }

  Future<void> _saveFile() async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String imagePath =
          '${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.png';
      await _image.copy(imagePath);

      final String textPath = '${appDir.path}/saved_texts.json';
      List<Map<String, String>> savedFiles = [];

      if (File(textPath).existsSync()) {
        String content = await File(textPath).readAsString();
        savedFiles = List<Map<String, dynamic>>.from(json.decode(content))
            .map((e) => e.cast<String, String>())
            .toList();
      }

      savedFiles.add({"imagePath": imagePath, "text": _extractedText});
      await File(textPath).writeAsString(json.encode(savedFiles));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saved Successfully!")),
      );
    } catch (e) {
      debugPrint("Save Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Image Preview")),
      body: Column(
        children: [
          Expanded(child: Image.file(_image, fit: BoxFit.contain)),

          if (_extractedText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_extractedText),
            ),

          /// **Raised Button Row (Moved 20px Up)**
          Padding(
            padding: const EdgeInsets.only(bottom: 40, top: 10), // ✅ Moved Up
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.crop),
                  label: const Text("Crop"),
                  onPressed: _cropImage,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("Save"),
                  onPressed: _saveFile,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.copy),
                  label: const Text("Copy"),
                  onPressed: _copyToClipboard,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
