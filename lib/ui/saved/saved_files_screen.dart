import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

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

        /// ✅ Ensure correct type casting
        List<Map<String, dynamic>> rawData =
            List<Map<String, dynamic>>.from(json.decode(content));

        setState(() {
          savedFiles = rawData.map((e) => e.cast<String, String>()).toList();
        });
      }
    } catch (e) {
      debugPrint("Error loading saved files: $e");
    }
  }

  /// **Copies text to clipboard**
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Copied to clipboard!")),
    );
  }

  /// **Deletes a saved item**
  void _deleteFile(int index) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String textPath = '${appDir.path}/saved_texts.json';

      // Delete image file
      File(savedFiles[index]["imagePath"]!).deleteSync();

      // Remove entry from list
      setState(() {
        savedFiles.removeAt(index);
      });

      // Save updated list
      await File(textPath).writeAsString(json.encode(savedFiles));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Deleted Successfully!")),
      );
    } catch (e) {
      debugPrint("Error deleting file: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Saved Files")),
      body: Padding(
        padding: const EdgeInsets.only(
            top: 20, bottom: 20), // ✅ Safe padding to avoid UI issues
        child: savedFiles.isEmpty
            ? const Center(child: Text("No saved files found."))
            : ListView.builder(
                itemCount: savedFiles.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        ListTile(
                          leading:
                              Image.file(File(savedFiles[index]["imagePath"]!)),
                          title: Text(
                            savedFiles[index]["text"] ?? "No text found",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == "copy") {
                                _copyToClipboard(savedFiles[index]["text"]!);
                              } else if (value == "delete") {
                                _deleteFile(index);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                  value: "copy", child: Text("Copy Text")),
                              const PopupMenuItem(
                                  value: "delete", child: Text("Delete")),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullImageScreen(
                                  imagePath: savedFiles[index]["imagePath"]!,
                                  extractedText: savedFiles[index]["text"]!,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

/// **Opens the image in full screen with extracted text**
class FullImageScreen extends StatelessWidget {
  final String imagePath;
  final String extractedText;

  const FullImageScreen(
      {super.key, required this.imagePath, required this.extractedText});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Full Image")),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: Image.file(File(imagePath), fit: BoxFit.contain)),
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    "Extracted Text:",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(extractedText, textAlign: TextAlign.center),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
