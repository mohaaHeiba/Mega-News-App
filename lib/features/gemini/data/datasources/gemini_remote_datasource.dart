/// lib/features/gemini/data/datasources/gemini_remote_datasource.dart
///
/// ده الـ DataSource الحقيقي اللي بيكلم package flutter_gemini
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:mega_news_app/core/errors/api_exception.dart';

abstract class IGeminiRemoteDataSource {
  Future<String> generateText(String prompt);
}

class GeminiRemoteDataSourceImpl implements IGeminiRemoteDataSource {
  final Gemini _gemini;

  GeminiRemoteDataSourceImpl(this._gemini);

  @override
  Future<String> generateText(String prompt) async {
    try {
      // 1. بنكلم الـ package
      final response = await _gemini.text(prompt);

      // 2. --- 🚀 التعديل النهائي هنا ---
      // الـ Getter الصحيح اسمه "output" مش "text"
      final text = response?.output;
      // --- نهاية التعديل ---

      if (text != null && text.isNotEmpty) {
        return text;
      } else {
        // لو الرد جه فاضي
        throw ServerException(message: 'Gemini returned an empty response.');
      }
    } catch (e) {
      // 3. لو الـ package نفسها رمت exception
      throw ServerException(message: 'Gemini API Error: ${e.toString()}');
    }
  }
}
