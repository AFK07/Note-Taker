import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoteEditor extends StatefulWidget {
  final String imagePath;
  final String initialNote;

  const NoteEditor({super.key, required this.imagePath, required this.initialNote});

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  late TextEditingController _noteController;
  List<File> attachedImages = [];
  bool hasStoragePermission = false;
  bool hasAskedPermission = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.initialNote);
    _checkPermissionStatus();
    _loadAttachedImages();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _checkPermissionStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    hasAskedPermission = prefs.getBool("hasAskedPermission") ?? false;

    if (!hasAskedPermission) {
      _showPermissionDialog();
    } else {
      _requestStoragePermission();
    }
  }

  Future<void> _showPermissionDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Allow Image Access"),
        content: const Text("Choose how you want to allow image access for notes."),
        actions: [
          TextButton(
            onPressed: () {
              prefs.setBool("hasAskedPermission", true);
              prefs.setString("imageAccess", "all");
              _requestStoragePermission();
              Navigator.pop(context);
            },
            child: const Text("Allow All"),
          ),
          TextButton(
            onPressed: () {
              prefs.setBool("hasAskedPermission", true);
              prefs.setString("imageAccess", "selected");
              _requestStoragePermission();
              Navigator.pop(context);
            },
            child: const Text("Allow Selected"),
          ),
          TextButton(
            onPressed: () {
              prefs.setBool("hasAskedPermission", true);
              prefs.setString("imageAccess", "none");
              Navigator.pop(context);
            },
            child: const Text("Deny"),
          ),
        ],
      ),
    );
  }

  Future<void> _requestStoragePermission() async {
    PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
      setState(() => hasStoragePermission = true);
    } else {
      setState(() => hasStoragePermission = false);
    }
  }

  Future<void> _loadAttachedImages() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String imagesPath = '${appDir.path}/notes_images.json';
    
    if (File(imagesPath).existsSync()) {
      String content = await File(imagesPath).readAsString();
      List<String> imagePaths = List<String>.from(json.decode(content));
      
      setState(() {
        attachedImages = imagePaths.map((path) => File(path)).toList();
      });
    }
  }

  Future<void> _pickImage() async {
    if (!hasStoragePermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Storage permission required to add images.")),
      );
      return;
    }
    
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String savedImagePath = '${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(pickedFile.path).copy(savedImagePath);

      setState(() {
        attachedImages.add(File(savedImagePath));
      });
      
      _saveAttachedImages();
    }
  }

  Future<void> _saveAttachedImages() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String imagesPath = '${appDir.path}/notes_images.json';
    List<String> imagePaths = attachedImages.map((file) => file.path).toList();
    await File(imagesPath).writeAsString(json.encode(imagePaths));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _noteController,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(
            hintText: "Enter your notes here...",
            border: OutlineInputBorder(),
          ),
          onChanged: (text) {
            // Auto-save note when text changes
          },
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text("Add Image"),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: attachedImages.map((image) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                image,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
