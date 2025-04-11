import 'package:flutter/material.dart';

class CapturePreviewActions extends StatelessWidget {
  final VoidCallback onCrop;
  final VoidCallback onSave;
  final VoidCallback onCopy;
  final VoidCallback onSummarize;
  final bool isSaved;
  final VoidCallback onBack; // New callback for the back button

  const CapturePreviewActions({
    super.key,
    required this.onCrop,
    required this.onSave,
    required this.onCopy,
    required this.onSummarize,
    required this.isSaved,
    required this.onBack, // Accept back callback
  });

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
          height: 70, // Reduce the height of the bottom bar
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Align items evenly across
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back,
                    color: Colors.white, size: 22), // Back icon
                tooltip: "Back",
                onPressed: onBack, // Navigate back to the previous screen
              ),
              IconButton(
                icon: const Icon(Icons.crop, color: Colors.white, size: 22),
                tooltip: "Crop",
                onPressed: onCrop,
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: child,
                ),
                child: IconButton(
                  key: ValueKey<bool>(isSaved),
                  icon: Icon(
                    isSaved ? Icons.check_circle : Icons.save_alt,
                    color: Colors.white,
                    size: 22,
                  ),
                  tooltip: isSaved ? "Saved" : "Save",
                  onPressed: onSave,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, color: Colors.white, size: 22),
                tooltip: "Copy",
                onPressed: onCopy,
              ),
              IconButton(
                icon: const Icon(Icons.notes, color: Colors.white, size: 22),
                tooltip: "Summarize",
                onPressed: onSummarize,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
