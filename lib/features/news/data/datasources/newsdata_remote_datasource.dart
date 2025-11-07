// lib/features/news/data/datasources/newsdata_remote_datasource.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mega_news_app/core/errors/api_exception.dart';
import 'package:mega_news_app/core/network/api_cleint.dart';
import 'package:mega_news_app/features/news/data/model/newsdata_response_model.dart';

abstract class INewsDataRemoteDataSource {
  Future<List<NewsDataArticleModel>> searchNews(String query);
  // --- 🚀 1. تعديل الـ Interface ---
  Future<List<NewsDataArticleModel>> getTopHeadlines({
    required String category,
  });
}

class NewsDataRemoteDataSourceImpl implements INewsDataRemoteDataSource {
  final ApiClient apiClient;

  NewsDataRemoteDataSourceImpl({required this.apiClient});

  final String _apiKey = dotenv.env['NEW_DATA']!;
  final String _baseUrl = 'https://newsdata.io/api/1';

  @override
  Future<List<NewsDataArticleModel>> searchNews(String query) async {
    // ... (الكود ده سليم زي ما هو) ...
    try {
      final responseMap = await apiClient.get(
        '$_baseUrl/news',
        queryParameters: {
          'q': query,
          'language': 'ar',
          'country': 'eg',
          'apikey': _apiKey,
        },
      );
      final responseModel = NewsdataResponseModel.fromJson(responseMap);
      return responseModel.results;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to parse NewsData search response: $e',
      );
    }
  }

  @override
  // --- 🚀 2. تعديل الـ Method ---
  Future<List<NewsDataArticleModel>> getTopHeadlines({
    required String category,
  }) async {
    // NewsData معندوش 'general', بنستخدم 'top' بدالها
    final String apiCategory = (category == 'general') ? 'top' : category;

    try {
      final responseMap = await apiClient.get(
        '$_baseUrl/news',
        queryParameters: {
          'language': 'ar',
          'country': 'eg',
          'apikey': _apiKey,
          'category': apiCategory, // <-- 🚀 3. إضافة الـ Category هنا
        },
      );
      final responseModel = NewsdataResponseModel.fromJson(responseMap);
      return responseModel.results;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to parse NewsData headlines response: $e',
      );
    }
  }
}
