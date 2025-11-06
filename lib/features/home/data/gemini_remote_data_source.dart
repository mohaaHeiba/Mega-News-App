import 'package:flutter_gemini/flutter_gemini.dart';

/// Wrapper around the Gemini SDK for generating summaries.
class GeminiRemoteDataSource {
  final Gemini _gemini = Gemini.instance;

  GeminiRemoteDataSource({String? apiKey}) {
    if (apiKey != null && apiKey.isNotEmpty) {
      Gemini.init(apiKey: apiKey);
    }
  }

  /// Generate a summary using the provided prompt.
  /// Returns the text output or throws an exception on failure.
  Future<String> generateSummary(String prompt) async {
    try {
      final response = await _gemini.text(prompt);
      if (response?.output != null && response!.output!.isNotEmpty) {
        return response.output!;
      } else {
        throw Exception(
          'Failed to generate summary: No output text in response.',
        );
      }
    } catch (e) {
      print('Error in Gemini API call: $e');
      throw Exception('Failed to communicate with AI model.');
    }
  }
}
