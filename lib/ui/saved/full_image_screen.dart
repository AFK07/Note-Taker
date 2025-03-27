import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_downloader/image_downloader.dart';
import 'dart:convert';
import 'package:dart_app/ui/saved/note_editor.dart';

class FullImageScreen extends StatefulWidget {
  final String imagePath;
  final String extractedText;
  final String timestamp;
  final String note;

  const FullImageScreen({
    super.key,
    required this.imagePath,
    required this.extractedText,
    required this.timestamp,
    required this.note,
  });

  @override
  State<FullImageScreen> createState() => _FullImageScreenState();
}

class _FullImageScreenState extends State<FullImageScreen> {
  late String userNote;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    userNote = widget.note;
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() => _isLoading = false);
    });
  }

  Future<void> _saveNote() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String textPath = '${appDir.path}/saved_texts.json';
    List<Map<String, String>> savedFiles = [];

    if (File(textPath).existsSync()) {
      String content = await File(textPath).readAsString();
      List<Map<String, dynamic>> rawData =
          List<Map<String, dynamic>>.from(json.decode(content));
      savedFiles = rawData.map((e) => e.cast<String, String>()).toList();
    }

    for (var file in savedFiles) {
      if (file["imagePath"] == widget.imagePath) {
        file["note"] = userNote;
        break;
      }
    }

    await File(textPath).writeAsString(json.encode(savedFiles));
  }

  Future<void> _downloadImage() async {
    try {
      await ImageDownloader.downloadImage(widget.imagePath);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Image downloaded')),
      );
    } catch (e) {
      debugPrint('❌ Download error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Download failed: $e')),
      );
    }
  }

  Future<void> _deleteImage() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String textPath = '${appDir.path}/saved_texts.json';

    if (File(widget.imagePath).existsSync()) {
      await File(widget.imagePath).delete();
    }

    if (File(textPath).existsSync()) {
      String content = await File(textPath).readAsString();
      List<Map<String, dynamic>> rawData =
          List<Map<String, dynamic>>.from(json.decode(content));
      rawData.removeWhere((file) => file["imagePath"] == widget.imagePath);
      await File(textPath).writeAsString(json.encode(rawData));
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  String _formatTimestamp(String timestamp) {
    try {
      DateTime dateTime = DateTime.parse(timestamp);
      return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
    } catch (e) {
      return "Unknown Time";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Full Image View"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Download',
            onPressed: _downloadImage,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _deleteImage();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'delete', child: Text('Delete Image')),
            ],
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  flex: 2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: PhotoView(
                      imageProvider: FileImage(File(widget.imagePath)),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 2,
                      backgroundDecoration:
                          const BoxDecoration(color: Colors.white),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            spreadRadius: 2),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "📅 Captured on: ${_formatTimestamp(widget.timestamp)}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "📜 Extracted Text:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.extractedText.isNotEmpty
                                ? widget.extractedText
                                : "No text found.",
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 10),
                          NoteEditor(
                            imagePath: widget.imagePath,
                            initialNote: userNote,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
