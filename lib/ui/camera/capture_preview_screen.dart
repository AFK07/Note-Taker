import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:dart_app/core/utils/text_extraction_util.dart';
import 'package:dart_app/core/services/gemini_service.dart';

class CapturePreviewScreen extends StatefulWidget {
  final XFile imageFile;
  const CapturePreviewScreen({super.key, required this.imageFile});

  @override
  CapturePreviewScreenState createState() => CapturePreviewScreenState();
}

class CapturePreviewScreenState extends State<CapturePreviewScreen>
    with SingleTickerProviderStateMixin {
  String extractedText = "";
  bool isProcessing = true;
  File? croppedFile;
  bool isSaved = false;
  String? lastSavedImagePath;

  final GeminiService geminiService = GeminiService();

  @override
  void initState() {
    super.initState();
    _processImage(File(widget.imageFile.path));
  }

  Future<void> _processImage(File imageFile) async {
    setState(() {
      isProcessing = true;
    });
    final result = await TextExtractionUtil.extractText(imageFile);
    if (!mounted) return;
    setState(() {
      extractedText = result;
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
      isSaved = false;
      await _processImage(croppedFile!);
    }
  }

  Future<void> _saveFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final targetPath =
        '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final sourcePath = croppedFile?.path ?? widget.imageFile.path;

    if (sourcePath == lastSavedImagePath) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Already saved.")),
      );
      return;
    }

    await File(sourcePath).copy(targetPath);
    lastSavedImagePath = sourcePath;

    final savedData = {
      "imagePath": targetPath,
      "text": extractedText,
      "timestamp": DateTime.now().toIso8601String(),
    };

    final textPath = '${directory.path}/saved_texts.json';
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
    setState(() {
      isSaved = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ File Saved Successfully")),
    );
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: extractedText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("📋 Text Copied to Clipboard")),
    );
  }

  Future<void> _summarizeText() async {
    try {
      final summary = await geminiService.summarizeText(
        "Summarize and explain what the following content is about:\n\n$extractedText",
      );
      if (!mounted) return;
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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to summarize: $e")),
      );
    }
  }

  Future<bool> _onWillPop() async {
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 1,
                maxScale: 4,
                child: Image.file(
                  File(croppedFile?.path ?? widget.imageFile.path),
                  fit: BoxFit.contain,
                  width: double.infinity,
                ),
              ),
            ),
            if (isProcessing)
              const Padding(
                padding: EdgeInsets.all(10),
                child: CircularProgressIndicator(),
              ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SingleChildScrollView(
                  child: Text(
                    extractedText.isNotEmpty ? extractedText : "No text found",
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 16, height: 1.1),
                    softWrap: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[900]?.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.crop,
                            color: Colors.white, size: 22),
                        tooltip: "Crop",
                        onPressed: _cropImage,
                      ),
                      IconButton(
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            isSaved ? Icons.check : Icons.save_alt,
                            key: ValueKey<bool>(isSaved),
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        tooltip: isSaved ? "Saved" : "Save",
                        onPressed: _saveFile,
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy,
                            color: Colors.white, size: 22),
                        tooltip: "Copy",
                        onPressed: _copyToClipboard,
                      ),
                      IconButton(
                        icon: const Icon(Icons.notes,
                            color: Colors.white, size: 22),
                        tooltip: "Summarize",
                        onPressed: _summarizeText,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
