import 'package:mega_news_app/core/errors/api_exception.dart';
import 'package:mega_news_app/core/network/api_cleint.dart';
import 'package:mega_news_app/core/utils/api_key_validator.dart';
import 'package:mega_news_app/core/utils/logger.dart';
import 'package:mega_news_app/features/news/data/model/newsapi_response_model.dart';

abstract class INewsApiRemoteDataSource {
  Future<List<NewsApiArticleModel>> searchNews(String query);
  Future<List<NewsApiArticleModel>> getTopHeadlines({required String category});
}

class NewsApiRemoteDataSourceImpl implements INewsApiRemoteDataSource {
  final ApiClient apiClient;
  String? _apiKey;
  final String _baseUrl = 'https://newsapi.org/v2';
  bool _isKeyValidated = false;

  NewsApiRemoteDataSourceImpl({required this.apiClient});

  /// Lazy validation of API key - validates on first use
  String get _validatedApiKey {
    if (!_isKeyValidated) {
      try {
        _apiKey = ApiKeyValidator.validateApiKey(
          'NEWS_API',
          customMessage: 'NewsAPI key is missing or invalid. Please check your .env file.',
        );
        _isKeyValidated = true;
        AppLogger.info('NewsAPI key validated successfully');
      } catch (e) {
        AppLogger.error('NewsAPI key validation failed', e);
        rethrow;
      }
    }
    return _apiKey!;
  }

  @override
  Future<List<NewsApiArticleModel>> searchNews(String query) async {
    try {
      AppLogger.debug('NewsAPI: Searching for "$query"');
      final responseMap = await apiClient.get(
        '$_baseUrl/everything',
        queryParameters: {'q': query, 'language': 'ar', 'apiKey': _validatedApiKey},
      );
      final responseModel = NewsapiResponseModel.fromJson(responseMap);
      AppLogger.info('NewsAPI: Found ${responseModel.articles.length} articles');
      return responseModel.articles;
    } on ApiException {
      rethrow;
    } catch (e) {
      AppLogger.apiError('NewsAPI', 'Failed to parse search response', e);
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
      AppLogger.debug('NewsAPI: Fetching top headlines for category "$category"');
      final responseMap = await apiClient.get(
        '$_baseUrl/top-headlines',
        queryParameters: {
          'language': 'ar',
          'country': 'eg',
          'apiKey': _validatedApiKey,
          'category': category,
        },
      );
      final responseModel = NewsapiResponseModel.fromJson(responseMap);
      AppLogger.info('NewsAPI: Found ${responseModel.articles.length} headlines');
      return responseModel.articles;
    } on ApiException {
      rethrow;
    } catch (e) {
      AppLogger.apiError('NewsAPI', 'Failed to parse headlines response', e);
      throw UnknownException(
        message: 'Failed to parse NewsAPI headlines response: $e',
      );
    }
  }
}
