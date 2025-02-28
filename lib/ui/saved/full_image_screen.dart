import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

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

  @override
  void initState() {
    super.initState();
    userNote = widget.note;
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

  void _editNote() {
    TextEditingController noteController =
        TextEditingController(text: userNote);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Note"),
          content: TextField(
            controller: noteController,
            decoration: const InputDecoration(hintText: "Enter your note"),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  userNote = noteController.text;
                });
                _saveNote();
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
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
            icon: const Icon(Icons.edit_note),
            onPressed: _editNote,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: PhotoView(
                imageProvider: FileImage(File(widget.imagePath)),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
                backgroundDecoration: const BoxDecoration(color: Colors.white),
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
                      color: Colors.black12, blurRadius: 4, spreadRadius: 2),
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
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.extractedText.isNotEmpty
                          ? widget.extractedText
                          : "No text found.",
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "📝 Notes:",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      userNote.isNotEmpty ? userNote : "No notes added.",
                      style: const TextStyle(
                          fontSize: 14, fontStyle: FontStyle.italic),
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
