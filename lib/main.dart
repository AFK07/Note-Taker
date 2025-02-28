import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dart_app/widgets/main_layout.dart';
import 'package:dart_app/ui/camera/camera_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp()); // ✅ MyApp can be const
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // ✅ Ensure MyApp has a const constructor

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Note Taker',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: MainLayout(child: const CameraScreen()), // ✅ Only child is const
    );
  }
}
