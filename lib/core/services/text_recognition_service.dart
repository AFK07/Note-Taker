import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/foundation.dart';

class TextRecognitionService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  /// Processes the image file and returns extracted text
  Future<String> extractTextFromImage(File image) async {
    try {
      final InputImage inputImage = InputImage.fromFile(image);
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      return recognizedText.text;
    } catch (e) {
      debugPrint('Error during text recognition: $e');
      return 'Error extracting text';
    }
  }

  /// Closes the text recognizer
  void dispose() {
    _textRecognizer.close();
  }
}
