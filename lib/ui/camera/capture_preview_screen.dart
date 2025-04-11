// Refactored version of capture_preview_screen.dart with image pop-up viewer and fixed bottom toolbar and image pop-up top toolbar
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:dart_app/core/utils/text_extraction_util.dart';
import 'package:dart_app/core/services/gemini_service.dart';

class CapturePreviewScreen extends StatefulWidget {
  final XFile imageFile;
  const CapturePreviewScreen({super.key, required this.imageFile});

  @override
  CapturePreviewScreenState createState() => CapturePreviewScreenState();
}

class CapturePreviewScreenState extends State<CapturePreviewScreen> {
  String extractedText = "";
  String originalExtractedText = "";
  bool isProcessing = true;
  File? croppedFile;
  bool isSaved = false;
  String? lastSavedImagePath;
  final GeminiService geminiService = GeminiService();
  bool isExtractedTextActive = true;
  bool isImagePopupVisible = false;

  @override
  void initState() {
    super.initState();
    _processImage(File(widget.imageFile.path));
  }

  Future<void> _processImage(File imageFile) async {
    setState(() => isProcessing = true);
    final result = await TextExtractionUtil.extractText(imageFile);
    if (!mounted) return;
    setState(() {
      extractedText = result;
      originalExtractedText = result;
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
      setState(() => isSaved = false);
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
    setState(() => isSaved = true);

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
      final summary = await geminiService.summarizeText(extractedText);
      if (!mounted) return;
      setState(() {
        extractedText = summary;
        isExtractedTextActive = false;
      });
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

  Widget _buildPopupImageOverlay() {
    return Positioned.fill(
      child: Column(
        children: [
          Container(
            color: Colors.black.withOpacity(0.8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => setState(() => isImagePopupVisible = false),
                ),
                IconButton(
                  icon: const Icon(Icons.fullscreen, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
                  onPressed: () => setState(() => isImagePopupVisible = false),
                ),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isImagePopupVisible = false),
              child: Container(
                color: Colors.black.withOpacity(0.85),
                alignment: Alignment.center,
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 1,
                  maxScale: 4,
                  child: Image.file(
                    File(croppedFile?.path ?? widget.imageFile.path),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isTextEmpty = extractedText.trim().isEmpty;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                if (!isImagePopupVisible)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => isImagePopupVisible = true),
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
                  ),
                if (isProcessing)
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: CircularProgressIndicator(),
                  ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(8, 8, 8, 60),
                    padding: const EdgeInsets.all(12),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black26),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isExtractedTextActive
                                ? "Extracted Text:"
                                : "Summarized Text:",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            extractedText.isNotEmpty
                                ? extractedText
                                : "(No text found)",
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (isImagePopupVisible) _buildPopupImageOverlay(),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                color: Colors.grey.shade900.withOpacity(0.95),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 20),
                      onPressed: () async {
                        if (await _onWillPop()) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.crop, color: Colors.white, size: 20),
                      onPressed: _cropImage,
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_red_eye,
                          color: Colors.white, size: 20),
                      onPressed: () => setState(() {
                        isExtractedTextActive = true;
                        extractedText = originalExtractedText;
                      }),
                    ),
                    IconButton(
                      icon: const Icon(Icons.summarize,
                          color: Colors.white, size: 20),
                      onPressed: _summarizeText,
                    ),
                    IconButton(
                      icon: Icon(
                        isSaved ? Icons.check_circle : Icons.save_alt,
                        key: ValueKey<bool>(isSaved),
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: _saveFile,
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.copy, color: Colors.white, size: 20),
                      onPressed: _copyToClipboard,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
