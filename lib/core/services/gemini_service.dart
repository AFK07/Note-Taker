import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  // Replace with your actual API key — ideally store securely
  static const String _apiKey = 'YOUR_API_KEY_HERE';

  // Corrected Gemini endpoint and model name
  static const String _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_apiKey';

  Future<String> summarizeText(String inputText) async {
    // Basic validation
    if (inputText.trim().isEmpty) {
      return "❗ Cannot summarize empty text.";
    }

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": "Summarize this text briefly:\n\n$inputText"}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final summary =
            decoded['candidates']?[0]?['content']?['parts']?[0]?['text'];
        return summary ?? "⚠️ No summary returned by the API.";
      } else {
        return "❌ Error: ${response.statusCode} ${response.reasonPhrase}";
      }
    } catch (e) {
      return "❌ Failed to summarize due to error: $e";
    }
  }
}
