import 'dart:convert';
import 'package:http/http.dart' as http;
import '../secrets.dart';

class AIService {
  // Groq API (OpenAI Compatible)
  static const String _apiUrl =
      "https://api.groq.com/openai/v1/chat/completions";

  Future<String> sendMessage(String text, {String? context}) async {
    try {
      final apiKey = GROQ_API_KEY.trim();

      // Build system prompt with context
      String systemPrompt =
          "You are SmartDrive, a helpful driving copilot. Keep answers short, concise, and helpful for a driver. Do not use markdown.";
      if (context != null && context.isNotEmpty) {
        systemPrompt += "\n\nCurrent Context:\n$context";
      }

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile", // Updated to supported model
          "messages": [
            {"role": "system", "content": systemPrompt},
            {"role": "user", "content": text},
          ],
          "max_tokens": 150,
          "temperature": 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = jsonDecode(response.body);
        if (result["choices"] != null &&
            (result["choices"] as List).isNotEmpty) {
          return result["choices"][0]["message"]["content"].trim();
        }
      } else {
        // ignore: avoid_print
        print("Groq API Error: ${response.statusCode}");
        print("Body: ${response.body}");
        final errBody = jsonDecode(response.body);
        final errMsg = errBody['error']?['message'] ?? response.body;
        return "Error ${response.statusCode}: $errMsg";
      }
    } catch (e) {
      // ignore: avoid_print
      print("AI Service Exception: $e");
      return "Connection error: $e";
    }
    return "Something went wrong.";
  }
}
