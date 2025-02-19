import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
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

        setState(() {
          savedFiles = rawData.map((e) => e.cast<String, String>()).toList();
        });

        debugPrint("✅ Successfully loaded ${savedFiles.length} saved files.");
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
                    onTap: () {
                      if (imagePath != null && File(imagePath).existsSync()) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullImageScreen(
                              imagePath: imagePath,
                              extractedText: extractedText ?? '',
                              timestamp: timestamp,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Image file not found!")),
                        );
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
