// lib/features/news/data/datasources/gnews_remote_datasource.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mega_news_app/core/errors/api_exception.dart';
import 'package:mega_news_app/core/network/api_cleint.dart';
import 'package:mega_news_app/features/news/data/model/gnews_response_model.dart';

abstract class IGNewsRemoteDataSource {
  Future<List<GNewsArticleModel>> searchNews(String query);
  // --- 🚀 1. تعديل الـ Interface ---
  Future<List<GNewsArticleModel>> getTopHeadlines({required String category});
}

class GNewsRemoteDataSourceImpl implements IGNewsRemoteDataSource {
  final ApiClient apiClient;

  GNewsRemoteDataSourceImpl({required this.apiClient});

  final String _apiKey = dotenv.env['GNEWS_API']!;
  final String _baseUrl = 'https://gnews.io/api/v4';

  @override
  Future<List<GNewsArticleModel>> searchNews(String query) async {
    // ... (الكود ده سليم زي ما هو) ...
    try {
      final responseMap = await apiClient.get(
        '$_baseUrl/search',
        queryParameters: {'q': query, 'lang': 'ar', 'apikey': _apiKey},
      );
      final responseModel = GnewsResponseModel.fromJson(responseMap);
      return responseModel.articles;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to parse GNews search response: $e',
      );
    }
  }

  @override
  // --- 🚀 2. تعديل الـ Method ---
  Future<List<GNewsArticleModel>> getTopHeadlines({
    required String category,
  }) async {
    try {
      final responseMap = await apiClient.get(
        '$_baseUrl/top-headlines',
        queryParameters: {
          'lang': 'ar',
          'country': 'eg',
          'apikey': _apiKey,
          'topic': category, // <-- 🚀 3. إضافة الـ Category هنا
        },
      );
      final responseModel = GnewsResponseModel.fromJson(responseMap);
      return responseModel.articles;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to parse GNews headlines response: $e',
      );
    }
  }
}
