import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

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
    final textRecognizer = TextRecognizer();
    final inputImage = InputImage.fromFile(imageFile);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    if (!mounted) return;
    setState(() {
      extractedText = recognizedText.text;
      isProcessing = false;
    });
  }

  Future<void> _cropImage() async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: widget.imageFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: false,
        ),
      ],
    );

    if (cropped != null) {
      setState(() {
        croppedFile = File(cropped.path);
        isProcessing = true;
      });
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("File Saved Successfully")),
    );

    Navigator.pop(
        context, true); // Ensure the screen reloads the saved files list
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
              child: Text(
                  extractedText.isNotEmpty ? extractedText : "No text found")),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(onPressed: _cropImage, child: const Text("Crop")),
              ElevatedButton(onPressed: _saveFile, child: const Text("Save")),
            ],
          ),
        ],
      ),
    );
  }
}
