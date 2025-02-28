import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:dart_app/ui/saved/full_image_screen.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<Map<String, String>> savedFiles = [];

  @override
  void initState() {
    super.initState();
    _loadSavedFiles();
  }

  Future<void> _loadSavedFiles() async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String textPath = '${appDir.path}/saved_texts.json';

      if (File(textPath).existsSync()) {
        String content = await File(textPath).readAsString();
        List<Map<String, dynamic>> rawData =
            List<Map<String, dynamic>>.from(json.decode(content));

        setState(() {
          savedFiles = rawData.map((e) => e.cast<String, String>()).toList();
        });
      }
    } catch (e) {
      debugPrint("Load Error: $e");
    }
  }

  Future<void> _saveUpdatedFiles() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String textPath = '${appDir.path}/saved_texts.json';
    await File(textPath).writeAsString(json.encode(savedFiles));
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("📋 Copied to clipboard!")),
    );
  }

  void _deleteFile(int index) async {
    bool confirmDelete = await _showDeleteConfirmation();
    if (!confirmDelete) return;

    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String textPath = '${appDir.path}/saved_texts.json';

      File(savedFiles[index]["imagePath"]!).deleteSync();
      setState(() {
        savedFiles.removeAt(index);
      });

      await File(textPath).writeAsString(json.encode(savedFiles));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🗑 Deleted Successfully!")),
      );
    } catch (e) {
      debugPrint("❌ Delete Error: $e");
    }
  }

  Future<bool> _showDeleteConfirmation() async {
    return await showDialog(
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("📁 Saved Files")),
      body: savedFiles.isEmpty
          ? const Center(child: Text("No saved files found."))
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: savedFiles.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.file(
                        File(savedFiles[index]["imagePath"]!),
                        fit: BoxFit.cover,
                        width: 60,
                        height: 60,
                      ),
                    ),
                    title: Text(
                      savedFiles[index]["text"] ?? "No text found",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                        "📅 ${savedFiles[index]["timestamp"] ?? "Unknown Time"}"),
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
                          value: "copy",
                          child: Text("📋 Copy Text"),
                        ),
                        const PopupMenuItem(
                          value: "delete",
                          child: Text("🗑 Delete"),
                        ),
                      ],
                    ),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullImageScreen(
                            imagePath: savedFiles[index]["imagePath"]!,
                            extractedText: savedFiles[index]["text"]!,
                            timestamp: savedFiles[index]["timestamp"] ?? '',
                            note: savedFiles[index]["note"] ?? "",
                          ),
                        ),
                      );
                      if (result != null && result is String) {
                        setState(() {
                          savedFiles[index]["note"] = result;
                        });
                        _saveUpdatedFiles();
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
