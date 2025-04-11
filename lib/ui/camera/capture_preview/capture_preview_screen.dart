import 'package:flutter/material.dart';

class CapturePreviewActions extends StatelessWidget {
  final VoidCallback onCrop;
  final VoidCallback onSave;
  final VoidCallback onCopy;
  final VoidCallback onSummarize;
  final bool isSaved;
  final VoidCallback onBack;

  const CapturePreviewActions({
    Key? key,
    required this.onCrop,
    required this.onSave,
    required this.onCopy,
    required this.onSummarize,
    required this.isSaved,
    required this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[900]?.withOpacity(0.95),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: onBack, // Add the back button functionality
              ),
              IconButton(
                icon: const Icon(Icons.crop, color: Colors.white),
                onPressed: onCrop,
              ),
              IconButton(
                icon: Icon(
                  isSaved ? Icons.check_circle : Icons.save_alt,
                  color: Colors.white,
                ),
                onPressed: onSave,
              ),
              IconButton(
                icon: const Icon(Icons.copy, color: Colors.white),
                onPressed: onCopy,
              ),
              IconButton(
                icon: const Icon(Icons.notes, color: Colors.white),
                onPressed: onSummarize,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
