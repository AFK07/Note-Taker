import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dart_app/widgets/main_layout.dart';
import 'package:dart_app/ui/home/home_screen.dart'; // Import HomeScreen instead of CameraScreen
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp()); // Ensure MyApp is const
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Note Taker',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const MainLayout(
          child: HomeScreen()), // Use HomeScreen as entry point
    );
  }
}
