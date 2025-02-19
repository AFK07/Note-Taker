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

      if (File(textPath).existsSync()) {
        String content = await File(textPath).readAsString();

        /// ✅ Fix JSON parsing
        List<Map<String, dynamic>> rawData =
            List<Map<String, dynamic>>.from(json.decode(content));

        setState(() {
          savedFiles = rawData.map((e) => e.cast<String, String>()).toList();
        });

        debugPrint("✅ Loaded ${savedFiles.length} saved files.");
      } else {
        debugPrint("⚠ No saved files found.");
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
          ? const Center(child: Text("No saved files found."))
          : ListView.builder(
              itemCount: savedFiles.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: Image.file(File(savedFiles[index]["imagePath"]!)),
                    title: Text(
                      savedFiles[index]["text"] ?? "No text found",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      "Captured on: ${_formatTimestamp(savedFiles[index]["timestamp"] ?? '')}",
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullImageScreen(
                            imagePath: savedFiles[index]["imagePath"]!,
                            extractedText: savedFiles[index]["text"]!,
                            timestamp: savedFiles[index]["timestamp"] ?? '',
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
