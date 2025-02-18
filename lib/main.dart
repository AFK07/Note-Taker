import 'package:flutter/material.dart';
import 'package:dart_app/ui/camera/camera_screen.dart'; // Make sure this file exists

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Note Taker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CameraScreen(), // ✅ Opens the camera first
    );
  }
}
