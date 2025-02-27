import 'package:flutter/material.dart';

class AudioScreen extends StatefulWidget {
  const AudioScreen({super.key});

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  bool _isRecording = false;

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });
    debugPrint(_isRecording
        ? "🎙 Recording button pressed"
        : "⏹ Stopping button pressed");
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 110,
          left: MediaQuery.of(context).size.width * 0.5 - 70,
          child: FloatingActionButton(
            heroTag: "record_audio",
            backgroundColor: Colors.blueAccent,
            onPressed: _toggleRecording,
            child:
                Icon(_isRecording ? Icons.pause : Icons.play_arrow, size: 30),
          ),
        ),
      ],
    );
  }
}
