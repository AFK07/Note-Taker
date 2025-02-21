import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for Clipboard
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:dart_app/ui/saved/full_image_screen.dart';

class SavedFilesScreen extends StatefulWidget {
  const SavedFilesScreen({super.key});

  @override
  State<SavedFilesScreen> createState() => _SavedFilesScreenState();
}

class _SavedFilesScreenState extends State<SavedFilesScreen> {
  List<Map<String, String>> savedFiles = [];

  @override
  void initState() {
    super.initState();
    _loadSavedFiles();
  }

  /// **Loads saved images & text from JSON**
  Future<void> _loadSavedFiles() async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String textPath = '${appDir.path}/saved_texts.json';

      debugPrint("📂 Checking if file exists: $textPath");

      if (!File(textPath).existsSync()) {
        debugPrint("⚠ No saved files found. File does not exist.");
        return;
      }

      String content = await File(textPath).readAsString();
      debugPrint("📖 Read JSON content: $content");

      if (content.trim().isEmpty) {
        debugPrint("⚠ JSON file is empty.");
        return;
      }

      try {
        List<Map<String, dynamic>> rawData =
            List<Map<String, dynamic>>.from(json.decode(content));

        if (mounted) {
          setState(() {
            savedFiles = rawData.map((e) => e.cast<String, String>()).toList();
          });
        }

        debugPrint("✅ Successfully loaded \${savedFiles.length} saved files.");
      } catch (e) {
        debugPrint("❌ JSON Parsing Error: $e");
      }
    } catch (e) {
      debugPrint("❌ Load Error: $e");
    }
  }

  /// **Formats timestamp for display**
  String _formatTimestamp(String timestamp) {
    try {
      DateTime dateTime = DateTime.parse(timestamp);
      return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
    } catch (e) {
      return "Unknown Time";
    }
  }

  /// **Deletes a saved file**
  void _deleteFile(int index) async {
    bool confirmDelete = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Delete File?"),
            content: const Text(
                "Are you sure you want to delete this file? This action cannot be undone."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child:
                    const Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmDelete) return;

    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String textPath = '${appDir.path}/saved_texts.json';

      // Delete image file
      File(savedFiles[index]["imagePath"]!).deleteSync();

      // Remove from list
      if (mounted) {
        setState(() {
          savedFiles.removeAt(index);
        });
      }

      // Save updated list
      await File(textPath).writeAsString(json.encode(savedFiles));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🗑 Deleted Successfully!")),
      );
    } catch (e) {
      debugPrint("❌ Delete Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Saved Files")),
      body: savedFiles.isEmpty
          ? const Center(
              child: Text(
                "No saved files found.",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: savedFiles.length,
              itemBuilder: (context, index) {
                String? imagePath = savedFiles[index]["imagePath"];
                String? extractedText = savedFiles[index]["text"];
                String timestamp = savedFiles[index]["timestamp"] ?? '';

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: imagePath != null && File(imagePath).existsSync()
                        ? Image.file(File(imagePath),
                            width: 60, height: 60, fit: BoxFit.cover)
                        : const Icon(Icons.image_not_supported,
                            size: 50, color: Colors.grey),
                    title: Text(
                      extractedText ?? "No text found",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      "Captured on: ${_formatTimestamp(timestamp)}",
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == "copy") {
                          Clipboard.setData(
                              ClipboardData(text: extractedText ?? ''));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("📋 Copied to clipboard!")),
                          );
                        } else if (value == "delete") {
                          _deleteFile(index);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                            value: "copy", child: Text("📋 Copy Text")),
                        const PopupMenuItem(
                            value: "delete", child: Text("🗑 Delete")),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
