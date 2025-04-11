import 'dart:io';
import 'package:flutter/material.dart';

class CapturePreviewImage extends StatelessWidget {
  final File imageFile;

  const CapturePreviewImage({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      panEnabled: true,
      minScale: 0.5,
      maxScale: 4.0,
      child: Image.file(
        imageFile,
        fit: BoxFit.contain,
        width: double.infinity,
      ),
    );
  }
}
