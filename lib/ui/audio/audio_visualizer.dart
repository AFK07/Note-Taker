import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:math';

class AudioVisualizerScreen extends StatefulWidget {
  const AudioVisualizerScreen({super.key});

  @override
  State<AudioVisualizerScreen> createState() => _AudioVisualizerScreenState();
}

class _AudioVisualizerScreenState extends State<AudioVisualizerScreen> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  bool _isAudioMode = false;
  double _currentVolume = 0.0;
  StreamSubscription? _recorderSubscription;
  final double _noiseThreshold = 10.0; // Adjust threshold as needed

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  /// **Initialize Microphone Recorder with Permissions**
  Future<void> _initRecorder() async {
    var status = await Permission.microphone.request();

    if (status.isGranted) {
      await _recorder.openRecorder();
      await _recorder
          .setSubscriptionDuration(const Duration(milliseconds: 100));
    } else {
      debugPrint("❌ Microphone permission denied!");
    }
  }

  /// **Start Recording & Visualizing**
  Future<void> _startRecording() async {
    if (!_recorder.isRecording) {
      await _recorder.startRecorder();
      setState(() {
        _isRecording = true;
        _isAudioMode = true;
      });

      _recorderSubscription = _recorder.onProgress?.listen((event) {
        double volume = event.decibels ?? 0.0;
        setState(() {
          _currentVolume = volume;
        });

        _detectSound(volume);
      });
    }
  }

  /// **Detects sound based on threshold**
  void _detectSound(double volume) {
    if (volume > _noiseThreshold) {
      debugPrint("✅ Sound detected: $volume dB");
    }
  }

  /// **Stop Recording**
  Future<void> _stopRecording() async {
    if (_recorder.isRecording) {
      try {
        await _recorder.stopRecorder();
        _recorderSubscription?.cancel();
        setState(() {
          _isRecording = false;
          _currentVolume = 0.0;
        });
        debugPrint("✅ Recorder stopped successfully!");
      } catch (e) {
        debugPrint("❌ Failed to stop recorder: $e");
      }
    } else {
      debugPrint("⚠️ Recorder is not active, skipping stop.");
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _recorderSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Audio Visualizer"),
        backgroundColor: Colors.black,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// **Sound Wave Visualizer**
          Expanded(
            child: Center(
              child: CustomPaint(
                size: const Size(double.infinity, 200),
                painter: WavePainter(_currentVolume),
              ),
            ),
          ),

          /// **Action Buttons**
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isAudioMode) ...[
                      FloatingActionButton(
                        backgroundColor: Colors.blueAccent,
                        onPressed: () => debugPrint("▶️ Play button pressed"),
                        child: const Icon(Icons.play_arrow, size: 30),
                      ),
                      const SizedBox(width: 20),
                      FloatingActionButton(
                        backgroundColor: Colors.blueAccent,
                        onPressed: () => debugPrint("⏹ Stop button pressed"),
                        child: const Icon(Icons.stop, size: 30),
                      ),
                    ]
                  ],
                ),
                const SizedBox(height: 20),
                FloatingActionButton(
                  backgroundColor: Colors.redAccent,
                  onPressed: _isRecording ? _stopRecording : _startRecording,
                  child: Icon(_isRecording ? Icons.stop : Icons.mic, size: 30),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// **Custom Painter for Sound Wave Animation**
class WavePainter extends CustomPainter {
  final double volume;
  WavePainter(this.volume);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final centerY = size.height / 2;
    final numBars = 30;
    final barSpacing = size.width / numBars;
    final maxHeight = size.height * 0.4;

    for (int i = 0; i < numBars; i++) {
      double barHeight = maxHeight * (volume / 100) * Random().nextDouble();
      canvas.drawLine(
        Offset(i * barSpacing, centerY - barHeight),
        Offset(i * barSpacing, centerY + barHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}
