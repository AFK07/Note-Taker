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

  /// **Copies text to clipboard**
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("📋 Copied to clipboard!")),
    );
  }

  /// **Deletes a saved file**
  void _deleteFile(int index) async {
    bool confirmDelete = await _showDeleteConfirmation();
    if (!confirmDelete) return;

    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String textPath = '${appDir.path}/saved_texts.json';

      // Delete image file
      File(savedFiles[index]["imagePath"]!).deleteSync();

      // Remove from list
      setState(() {
        savedFiles.removeAt(index);
      });

      // Save updated list
      await File(textPath).writeAsString(json.encode(savedFiles));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🗑 Deleted Successfully!")),
      );
    } catch (e) {
      debugPrint("❌ Delete Error: $e");
    }
  }

  /// **Shows confirmation dialog before deleting**
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
                      "📅 ${_formatTimestamp(savedFiles[index]["timestamp"] ?? '')}",
                      style: const TextStyle(fontSize: 12),
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
                          value: "copy",
                          child: Text("📋 Copy Text"),
                        ),
                        const PopupMenuItem(
                          value: "delete",
                          child: Text("🗑 Delete"),
                        ),
                      ],
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
                    onLongPress: () =>
                        _copyToClipboard(savedFiles[index]["text"]!),
                  ),
                );
              },
            ),
    );
  }
}
