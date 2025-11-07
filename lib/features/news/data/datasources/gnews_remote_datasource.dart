import 'package:mega_news_app/core/errors/api_exception.dart';
import 'package:mega_news_app/core/network/api_cleint.dart';
import 'package:mega_news_app/core/utils/api_key_validator.dart';
import 'package:mega_news_app/core/utils/logger.dart';
import 'package:mega_news_app/features/news/data/model/gnews_response_model.dart';

abstract class IGNewsRemoteDataSource {
  Future<List<GNewsArticleModel>> searchNews(String query);
  Future<List<GNewsArticleModel>> getTopHeadlines({required String category});
}

class GNewsRemoteDataSourceImpl implements IGNewsRemoteDataSource {
  final ApiClient apiClient;
  String? _apiKey;
  final String _baseUrl = 'https://gnews.io/api/v4';
  bool _isKeyValidated = false;

  GNewsRemoteDataSourceImpl({required this.apiClient});

  /// Lazy validation of API key - validates on first use
  String get _validatedApiKey {
    if (!_isKeyValidated) {
      try {
        _apiKey = ApiKeyValidator.validateApiKey(
          'GNEWS_API',
          customMessage: 'GNews API key is missing or invalid. Please check your .env file.',
        );
        _isKeyValidated = true;
        AppLogger.info('GNews API key validated successfully');
      } catch (e) {
        AppLogger.error('GNews API key validation failed', e);
        rethrow;
      }
    }
    return _apiKey!;
  }

  @override
  Future<List<GNewsArticleModel>> searchNews(String query) async {
    try {
      AppLogger.debug('GNews: Searching for "$query"');
      final responseMap = await apiClient.get(
        '$_baseUrl/search',
        queryParameters: {'q': query, 'lang': 'ar', 'apikey': _validatedApiKey},
      );
      final responseModel = GnewsResponseModel.fromJson(responseMap);
      AppLogger.info('GNews: Found ${responseModel.articles.length} articles');
      return responseModel.articles;
    } on ApiException {
      rethrow;
    } catch (e) {
      AppLogger.apiError('GNews', 'Failed to parse search response', e);
      throw UnknownException(
        message: 'Failed to parse GNews search response: $e',
      );
    }
  }

  @override
  Future<List<GNewsArticleModel>> getTopHeadlines({
    required String category,
  }) async {
    try {
      AppLogger.debug('GNews: Fetching top headlines for category "$category"');
      final responseMap = await apiClient.get(
        '$_baseUrl/top-headlines',
        queryParameters: {
          'lang': 'ar',
          'country': 'eg',
          'apikey': _validatedApiKey,
          'topic': category,
        },
      );
      final responseModel = GnewsResponseModel.fromJson(responseMap);
      AppLogger.info('GNews: Found ${responseModel.articles.length} headlines');
      return responseModel.articles;
    } on ApiException {
      rethrow;
    } catch (e) {
      AppLogger.apiError('GNews', 'Failed to parse headlines response', e);
      throw UnknownException(
        message: 'Failed to parse GNews headlines response: $e',
      );
    }
  }
}
