/// lib/features/gemini/data/repositories/gemini_repository_impl.dart
///
/// ده "الكوبري" اللي بيربط الـ DataSource بالـ Interface بتاع الـ Domain
import 'package:mega_news_app/core/errors/api_exception.dart';
import 'package:mega_news_app/features/gemini/data/datasources/gemini_remote_datasource.dart';
import 'package:mega_news_app/features/gemini/domain/repositories/i_gemini_repository.dart';

class GeminiRepositoryImpl implements IGeminiRepository {
  final IGeminiRemoteDataSource _dataSource;

  GeminiRepositoryImpl(this._dataSource);

  @override
  Future<String> generateText(String prompt) async {
    try {
      // 1. بنطلب الداتا من الـ DataSource
      return await _dataSource.generateText(prompt);
    } on ApiException {
      // 2. لو الـ DataSource رمى ApiException, بنرميه زي ما هو
      rethrow;
    } catch (e) {
      // 3. لأي خطأ غير متوقع
      throw UnknownException(message: 'Gemini Repository Error: $e');
    }
  }
}
