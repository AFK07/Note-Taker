import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextExtractionUtil {
  /// Extracts and formats text from an image file
  static Future<String> extractText(File imageFile) async {
    final textRecognizer = TextRecognizer();
    final inputImage = InputImage.fromFile(imageFile);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    return _formatText(recognizedText);
  }

  /// Formats detected text with paragraphs, bullet points, and numbered lists
  static String _formatText(RecognizedText recognizedText) {
    StringBuffer formattedText = StringBuffer();

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        String text = line.text.trim();

        if (RegExp(r'^[•\-]\s').hasMatch(text)) {
          formattedText.writeln(text);
        } else if (RegExp(r'^\d+\.\s').hasMatch(text)) {
          formattedText.writeln(text);
        } else {
          formattedText.writeln("\n$text");
        }
      }
    }
    return formattedText.toString().trim();
  }
}
