import 'package:flutter/material.dart';

class CapturePreviewText extends StatelessWidget {
  final String extractedText;

  const CapturePreviewText({
    super.key,
    required this.extractedText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: SingleChildScrollView(
        child: Text(
          extractedText.isNotEmpty ? extractedText : "No text found.",
          style: const TextStyle(
            fontSize: 16,
            height: 1.4,
            color: Colors.black87,
          ),
          textAlign: TextAlign.left,
          softWrap: true,
        ),
      ),
    );
  }
}
