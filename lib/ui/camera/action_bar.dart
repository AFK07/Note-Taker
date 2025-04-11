import 'package:flutter/material.dart';

class ActionBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onGallery;
  final VoidCallback onCamera;
  final VoidCallback onAudio;
  final VoidCallback onShare;

  const ActionBar({
    super.key,
    required this.onBack,
    required this.onGallery,
    required this.onCamera,
    required this.onAudio,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: onBack,
          ),
          IconButton(
            icon: const Icon(Icons.photo_library, color: Colors.white),
            onPressed: onGallery,
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            onPressed: onCamera,
          ),
          IconButton(
            icon: const Icon(Icons.mic, color: Colors.white),
            onPressed: onAudio,
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: onShare,
          ),
        ],
      ),
    );
  }
}
