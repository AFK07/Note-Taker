import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:dart_app/core/utils/text_extraction_util.dart';

class CapturePreviewScreen extends StatefulWidget {
  final XFile imageFile;
  const CapturePreviewScreen({super.key, required this.imageFile});
  @override
  CapturePreviewScreenState createState() => CapturePreviewScreenState();
}

class CapturePreviewScreenState extends State<CapturePreviewScreen> {
  String extractedText = "";
  bool isProcessing = true;
  File? croppedFile;

  @override
  void initState() {
    super.initState();
    _processImage(File(widget.imageFile.path));
  }

  Future<void> _processImage(File imageFile) async {
    setState(() => isProcessing = true);
    String text = await TextExtractionUtil.extractText(imageFile);
    if (!mounted) return;
    setState(() {
      extractedText = text;
      isProcessing = false;
    });
  }

  Future<void> _cropImage() async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: widget.imageFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: false,
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: false,
          resetAspectRatioEnabled: true,
        ),
      ],
    );
    if (cropped != null) {
      croppedFile = File(cropped.path);
      _processImage(croppedFile!);
    }
  }

  Future<void> _saveFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final savedImagePath =
        '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(croppedFile?.path ?? widget.imageFile.path).copy(savedImagePath);

    final savedData = {
      "imagePath": savedImagePath,
      "text": extractedText,
      "timestamp": DateTime.now().toIso8601String(),
    };

    final String textPath = '${directory.path}/saved_texts.json';
    List<Map<String, String>> savedFiles = [];
    if (File(textPath).existsSync()) {
      String content = await File(textPath).readAsString();
      if (content.isNotEmpty) {
        List<Map<String, dynamic>> rawData =
            List<Map<String, dynamic>>.from(json.decode(content));
        savedFiles = rawData.map((e) => e.cast<String, String>()).toList();
      }
    }
    savedFiles.add(savedData);
    await File(textPath).writeAsString(json.encode(savedFiles));

    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("File Saved Successfully")));
    Navigator.pop(context, true);
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: extractedText));
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Text Copied to Clipboard")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Preview")),
      body: Column(
        children: [
          Expanded(
              child:
                  Image.file(File(croppedFile?.path ?? widget.imageFile.path))),
          if (isProcessing) const CircularProgressIndicator(),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SingleChildScrollView(
                child: Text(
                  extractedText.isNotEmpty ? extractedText : "No text found",
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.1, // Reduced line spacing (adjust as needed)
                  ),
                  softWrap: true,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(onPressed: _cropImage, child: const Text("Crop")),
              ElevatedButton(onPressed: _saveFile, child: const Text("Save")),
              ElevatedButton(
                  onPressed: _copyToClipboard, child: const Text("Copy")),
            ],
          ),
        ],
      ),
    );
  }
}
