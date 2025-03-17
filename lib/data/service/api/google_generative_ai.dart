import 'dart:developer';

import 'package:google_generative_ai/google_generative_ai.dart';

class GenerativeAiWebService {
  static final _model = GenerativeModel(
    model: 'gemini-2.0-flash',
    apiKey: 'AIzaSyCc_RgZftsJWzvZ2_bMqwveG3Lr0Nuzlw0',
  );
  static Future<String?> postData({required String text}) async {
    try {
      print("postData() called with text: $text");

      // System prompt to set the context
      const systemPrompt = '''
You are MediAssistAI, a virtual assistant in the MediAssistAI app. 
Your role is to provide solutions, advice, and information for symptoms, health concerns, and general medical queries. 
Always respond in a professional, empathetic, and helpful manner. 
If the user asks unrelated questions, politely guide them back to health-related topics.
''';

      // Combine the system prompt with the user's message
      final content = [
        Content.text(systemPrompt), // System prompt
        Content.text(text), // User's message
      ];

      final response = await _model.generateContent(content);

      print("Raw API response: ${response.text}");

      if (response.text == null) {
        print('Response is null');
        return "ERROR";
      }

      final cleanResponse = response.text!.trim();
      print('Clean response: $cleanResponse');
      return cleanResponse;
    } catch (err) {
      print("Error in postData: ${err.toString()}");
      return "ERROR";
    }
  }

  static Future<void> streamData({required String text}) async {
    final content = [Content.text(text)];
    final response = _model.generateContentStream(content);
    await for (final chunk in response) {
      log(chunk.text!);
    }
  }
}
