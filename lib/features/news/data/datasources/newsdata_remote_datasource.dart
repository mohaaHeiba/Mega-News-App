// lib/features/news/data/datasources/newsdata_remote_datasource.dart
import 'package:mega_news_app/core/errors/api_exception.dart';
import 'package:mega_news_app/core/network/api_cleint.dart';
import 'package:mega_news_app/core/utils/api_key_validator.dart';
import 'package:mega_news_app/core/utils/logger.dart';
import 'package:mega_news_app/features/news/data/model/newsdata_response_model.dart';

abstract class INewsDataRemoteDataSource {
  Future<List<NewsDataArticleModel>> searchNews(String query);
  Future<List<NewsDataArticleModel>> getTopHeadlines({
    required String category,
  });
}

class NewsDataRemoteDataSourceImpl implements INewsDataRemoteDataSource {
  final ApiClient apiClient;
  String? _apiKey;
  final String _baseUrl = 'https://newsdata.io/api/1';
  bool _isKeyValidated = false;

  NewsDataRemoteDataSourceImpl({required this.apiClient});

  /// Lazy validation of API key - validates on first use
  String get _validatedApiKey {
    if (!_isKeyValidated) {
      try {
        _apiKey = ApiKeyValidator.validateApiKey(
          'NEW_DATA',
          customMessage: 'NewsData API key is missing or invalid. Please check your .env file.',
        );
        _isKeyValidated = true;
        AppLogger.info('NewsData API key validated successfully');
      } catch (e) {
        AppLogger.error('NewsData API key validation failed', e);
        rethrow;
      }
    }
    return _apiKey!;
  }

  @override
  Future<List<NewsDataArticleModel>> searchNews(String query) async {
    try {
      AppLogger.debug('NewsData: Searching for "$query"');
      final responseMap = await apiClient.get(
        '$_baseUrl/news',
        queryParameters: {
          'q': query,
          'language': 'ar',
          'country': 'eg',
          'apikey': _validatedApiKey,
        },
      );
      final responseModel = NewsdataResponseModel.fromJson(responseMap);
      AppLogger.info('NewsData: Found ${responseModel.results.length} articles');
      return responseModel.results;
    } on ApiException {
      rethrow;
    } catch (e) {
      AppLogger.apiError('NewsData', 'Failed to parse search response', e);
      throw UnknownException(
        message: 'Failed to parse NewsData search response: $e',
      );
    }
  }

  @override
  Future<List<NewsDataArticleModel>> getTopHeadlines({
    required String category,
  }) async {
    final String apiCategory = (category == 'general') ? 'top' : category;

    try {
      AppLogger.debug('NewsData: Fetching top headlines for category "$category"');
      final responseMap = await apiClient.get(
        '$_baseUrl/news',
        queryParameters: {
          'language': 'ar',
          'country': 'eg',
          'apikey': _validatedApiKey,
          'category': apiCategory,
        },
      );
      final responseModel = NewsdataResponseModel.fromJson(responseMap);
      AppLogger.info('NewsData: Found ${responseModel.results.length} headlines');
      return responseModel.results;
    } on ApiException {
      rethrow;
    } catch (e) {
      AppLogger.apiError('NewsData', 'Failed to parse headlines response', e);
      throw UnknownException(
        message: 'Failed to parse NewsData headlines response: $e',
      );
    }
  }
}
