import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // ✅ Import for formatting date/time
import 'package:photo_view/photo_view.dart'; // ✅ Zoomable image support

class FullImageScreen extends StatelessWidget {
  final String imagePath;
  final String extractedText;
  final String timestamp; // ✅ Ensure timestamp is defined

  const FullImageScreen({
    super.key,
    required this.imagePath,
    required this.extractedText,
    required this.timestamp, // ✅ Now included in constructor
  });

  /// **Formats the timestamp into a readable format**
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
      appBar: AppBar(title: const Text("📷 Full Image View")),
      body: Column(
        children: [
          Expanded(
            flex: 7, // ✅ 70% of the screen for the image
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: PhotoView(
                imageProvider: FileImage(File(imagePath)),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
                backgroundDecoration: const BoxDecoration(color: Colors.white),
              ),
            ),
          ),
          Expanded(
            flex: 3, // ✅ 30% of the screen for text
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
                      "📅 Captured on: ${_formatTimestamp(timestamp)}", // ✅ Show formatted time
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
                      extractedText.isNotEmpty
                          ? extractedText
                          : "No text found.",
                      style: const TextStyle(fontSize: 14),
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
