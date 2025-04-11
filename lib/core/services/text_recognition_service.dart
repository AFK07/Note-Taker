import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/foundation.dart';

class TextRecognitionService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  /// Enhanced text extraction with smart formatting
  Future<String> extractTextFromImage(File image) async {
    try {
      final InputImage inputImage = InputImage.fromFile(image);
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      final StringBuffer formattedText = StringBuffer();

      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          String lineText = line.text.trim();

          final isBullet =
              RegExp(r'^(•|\*|\-|\•)\s+'); // includes Unicode bullets
          final isNumbered = RegExp(r'^(\d+)[\.\)]\s+'); // e.g., 1. or 2)
          final isCheckbox = RegExp(r'^\[\s?\]'); // [ ] checkbox
          final isCodeLike = RegExp(r'^\d+\$'); // single line numbers
          final isCodeFile = RegExp(r'\.(dart|py|js|ts|java|txt|json|yaml)\$');
          final isTitle = lineText.toLowerCase().endsWith(':');
          final isLikelyBulletByIndent =
              lineText.startsWith(RegExp(r'\s{2,}')) &&
                  lineText.split(' ').length <= 10;

          if (isBullet.hasMatch(lineText)) {
            formattedText
                .writeln('• ${lineText.replaceFirst(isBullet, '').trim()}');
          } else if (isCheckbox.hasMatch(lineText)) {
            formattedText
                .writeln('☐ ${lineText.replaceFirst(isCheckbox, '').trim()}');
          } else if (isLikelyBulletByIndent) {
            formattedText.writeln('• $lineText');
          } else if (isCodeFile.hasMatch(lineText)) {
            formattedText.writeln('``` ${lineText.trim()} ```');
          } else if (isTitle) {
            formattedText.writeln('\n📌 ${lineText.trim()}');
          } else if (isNumbered.hasMatch(lineText)) {
            formattedText.writeln(lineText);
          } else if (!isCodeLike.hasMatch(lineText)) {
            formattedText.writeln(lineText);
          } // skip pure line numbers if not numbered list
        }
        formattedText.writeln();
      }

      return formattedText.toString().trim();
    } catch (e) {
      debugPrint('Error during text recognition: $e');
      return 'Error extracting text';
    }
  }

  /// Dispose text recognizer resources
  void dispose() {
    _textRecognizer.close();
  }
}
