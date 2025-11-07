import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mega_news_app/core/errors/api_exception.dart';
import 'package:mega_news_app/core/network/api_cleint.dart';
import 'package:mega_news_app/features/news/data/model/newsapi_response_model.dart';

abstract class INewsApiRemoteDataSource {
  Future<List<NewsApiArticleModel>> searchNews(String query);
  Future<List<NewsApiArticleModel>> getTopHeadlines({required String category});
}

class NewsApiRemoteDataSourceImpl implements INewsApiRemoteDataSource {
  final ApiClient apiClient;

  NewsApiRemoteDataSourceImpl({required this.apiClient});

  final String _apiKey = dotenv.env['NEWS_API']!;
  final String _baseUrl = 'https://newsapi.org/v2';

  @override
  Future<List<NewsApiArticleModel>> searchNews(String query) async {
    try {
      final responseMap = await apiClient.get(
        '$_baseUrl/everything',
        queryParameters: {'q': query, 'language': 'ar', 'apiKey': _apiKey},
      );
      final responseModel = NewsapiResponseModel.fromJson(responseMap);
      return responseModel.articles;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to parse NewsAPI search response: $e',
      );
    }
  }

  @override
  Future<List<NewsApiArticleModel>> getTopHeadlines({
    required String category,
  }) async {
    try {
      final responseMap = await apiClient.get(
        '$_baseUrl/top-headlines',
        queryParameters: {
          'language': 'ar',
          'country': 'eg',
          'apiKey': _apiKey,
          'category': category,
        },
      );
      final responseModel = NewsapiResponseModel.fromJson(responseMap);
      return responseModel.articles;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to parse NewsAPI headlines response: $e',
      );
    }
  }
}
