// lib/features/news/data/repositories/news_repository_impl.dart

import 'package:mega_news_app/core/errors/api_exception.dart';
import 'package:mega_news_app/core/utils/logger.dart';
import 'package:mega_news_app/features/news/data/datasources/gnews_remote_datasource.dart';
import 'package:mega_news_app/features/news/data/datasources/newsapi_remote_datasource.dart';
import 'package:mega_news_app/features/news/data/datasources/newsdata_remote_datasource.dart';
import 'package:mega_news_app/features/news/data/mappers/article_mapper.dart';
import 'package:mega_news_app/features/news/domain/entities/article.dart';
import 'package:mega_news_app/features/news/domain/repositories/i_news_repository.dart';

class NewsRepositoryImpl implements INewsRepository {
  final IGNewsRemoteDataSource gNewsDataSource;
  final INewsApiRemoteDataSource newsApiDataSource;
  final INewsDataRemoteDataSource newsDataDataSource;
  final ArticleMapper mapper;

  NewsRepositoryImpl({
    required this.gNewsDataSource,
    required this.newsApiDataSource,
    required this.newsDataDataSource,
    required this.mapper,
  });

  // ==============================================================
  // Fetch top headlines by category
  // Handles errors gracefully: if one API fails, continues with others
  // Only throws if ALL APIs fail
  // Runs all APIs in parallel for better performance
  // ==============================================================
  @override
  Future<List<Article>> getTopHeadlines({required String category}) async {
    final List<Article> allArticles = [];
    final List<String> failedApis = [];

    // Fetch from all APIs in parallel with individual error handling
    final results = await Future.wait([
      _fetchGNewsHeadlines(category).catchError((e) {
        failedApis.add('GNews');
        _logApiError('GNews', 'Failed to fetch headlines', e);
        return <Article>[];
      }),
      _fetchNewsApiHeadlines(category).catchError((e) {
        failedApis.add('NewsAPI');
        _logApiError('NewsAPI', 'Failed to fetch headlines', e);
        return <Article>[];
      }),
      _fetchNewsDataHeadlines(category).catchError((e) {
        failedApis.add('NewsData');
        _logApiError('NewsData', 'Failed to fetch headlines', e);
        return <Article>[];
      }),
    ], eagerError: false);

    // Combine all successful results
    final gnewsArticles = results[0];
    final newsApiArticles = results[1];
    final newsDataArticles = results[2];

    allArticles.addAll(gnewsArticles);
    allArticles.addAll(newsApiArticles);
    allArticles.addAll(newsDataArticles);

    // If all APIs failed, throw an error
    if (allArticles.isEmpty && failedApis.length == 3) {
      throw UnknownException(
        message: 'All news APIs failed. GNews: failed, NewsAPI: failed, NewsData: failed',
      );
    }

    // If some APIs failed but we have results, log a warning but continue
    if (failedApis.isNotEmpty && allArticles.isNotEmpty) {
      AppLogger.warning(
        'Some APIs failed (${failedApis.join(', ')}), but continuing with ${allArticles.length} articles from working APIs',
      );
    }

    // Deduplicate & sort by date
    return _processAndSortArticles(allArticles);
  }

  // Helper method to fetch from GNews
  Future<List<Article>> _fetchGNewsHeadlines(String category) async {
    final gnewsRaw = await gNewsDataSource.getTopHeadlines(category: category);
    return gnewsRaw.map(mapper.fromGNewsModel).toList();
  }

  // Helper method to fetch from NewsAPI
  Future<List<Article>> _fetchNewsApiHeadlines(String category) async {
    final newsApiRaw = await newsApiDataSource.getTopHeadlines(category: category);
    return newsApiRaw.map(mapper.fromNewsApiModel).toList();
  }

  // Helper method to fetch from NewsData
  Future<List<Article>> _fetchNewsDataHeadlines(String category) async {
    final newsDataRaw = await newsDataDataSource.getTopHeadlines(category: category);
    return newsDataRaw.map(mapper.fromNewsDataModel).toList();
  }

  // ==============================================================
  // Search news by keyword
  // Handles errors gracefully: if one API fails, continues with others
  // Only throws if ALL APIs fail
  // Runs all APIs in parallel for better performance
  // ==============================================================
  @override
  Future<List<Article>> searchNews(String query) async {
    final List<Article> allArticles = [];
    final List<String> failedApis = [];

    // Fetch from all APIs in parallel with individual error handling
    final results = await Future.wait([
      _searchGNews(query).catchError((e) {
        failedApis.add('GNews');
        _logApiError('GNews', 'Failed to search news', e);
        return <Article>[];
      }),
      _searchNewsApi(query).catchError((e) {
        failedApis.add('NewsAPI');
        _logApiError('NewsAPI', 'Failed to search news', e);
        return <Article>[];
      }),
      _searchNewsData(query).catchError((e) {
        failedApis.add('NewsData');
        _logApiError('NewsData', 'Failed to search news', e);
        return <Article>[];
      }),
    ], eagerError: false);

    // Combine all successful results
    final gnewsArticles = results[0];
    final newsApiArticles = results[1];
    final newsDataArticles = results[2];

    allArticles.addAll(gnewsArticles);
    allArticles.addAll(newsApiArticles);
    allArticles.addAll(newsDataArticles);

    // If all APIs failed, throw an error
    if (allArticles.isEmpty && failedApis.length == 3) {
      throw UnknownException(
        message: 'All news APIs failed. GNews: failed, NewsAPI: failed, NewsData: failed',
      );
    }

    // If some APIs failed but we have results, log a warning but continue
    if (failedApis.isNotEmpty && allArticles.isNotEmpty) {
      AppLogger.warning(
        'Some APIs failed (${failedApis.join(', ')}), but continuing with ${allArticles.length} articles from working APIs',
      );
    }

    // Deduplicate & sort by date
    return _processAndSortArticles(allArticles);
  }

  // Helper method to search GNews
  Future<List<Article>> _searchGNews(String query) async {
    final gnewsRaw = await gNewsDataSource.searchNews(query);
    return gnewsRaw.map(mapper.fromGNewsModel).toList();
  }

  // Helper method to search NewsAPI
  Future<List<Article>> _searchNewsApi(String query) async {
    final newsApiRaw = await newsApiDataSource.searchNews(query);
    return newsApiRaw.map(mapper.fromNewsApiModel).toList();
  }

  // Helper method to search NewsData
  Future<List<Article>> _searchNewsData(String query) async {
    final newsDataRaw = await newsDataDataSource.searchNews(query);
    return newsDataRaw.map(mapper.fromNewsDataModel).toList();
  }

  // ==============================================================
  // Private helper: remove duplicates & sort by newest first
  // ==============================================================
  List<Article> _processAndSortArticles(List<Article> articles) {
    // Remove duplicates based on article ID
    final uniqueArticles = articles.toSet().toList();

    // Sort by publish date (descending)
    uniqueArticles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    return uniqueArticles;
  }

  // ==============================================================
  // Private helper: Log API errors with categorization
  // ==============================================================
  void _logApiError(String apiName, String context, dynamic error) {
    if (error is ApiException) {
      if (error is ForbiddenException || error is UnauthorizedException) {
        AppLogger.error(
          '[$apiName API] Authentication error in $context',
          error,
        );
      } else if (error is RateLimitException) {
        AppLogger.warning(
          '[$apiName API] Rate limit exceeded in $context. Retry after: ${error.retryAfter?.inSeconds ?? 'unknown'}s',
        );
      } else if (error is NetworkException) {
        AppLogger.warning('[$apiName API] Network error in $context');
      } else {
        AppLogger.apiError(apiName, context, error);
      }
    } else {
      AppLogger.apiError(apiName, context, error);
    }
  }
}
