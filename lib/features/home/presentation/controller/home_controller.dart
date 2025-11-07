// lib/features/news/presentation/controllers/home_controller.dart

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';
import 'package:mega_news_app/core/errors/api_exception.dart';
import 'package:mega_news_app/core/network/api_cleint.dart';
import 'package:mega_news_app/core/service/error_handler_service.dart';
import 'package:mega_news_app/features/news/data/datasources/gnews_remote_datasource.dart';
import 'package:mega_news_app/features/news/data/datasources/newsapi_remote_datasource.dart';
import 'package:mega_news_app/features/news/data/datasources/newsdata_remote_datasource.dart';
import 'package:mega_news_app/features/news/data/mappers/article_mapper.dart';
import 'package:mega_news_app/features/news/domain/entities/article.dart';
import 'package:mega_news_app/features/news/domain/repositories/i_news_repository.dart';
import 'package:mega_news_app/features/news/domain/repositories/news_repository_impl.dart';
import 'package:mega_news_app/generated/l10n.dart';

class HomeController extends GetxController {
  // ==============================================================
  // Repository Instance
  // ==============================================================
  late final INewsRepository _newsRepository;
  final _storage = GetStorage();

  // ==============================================================
  // Cache Keys
  // ==============================================================
  static const String _cachePrefix = 'cached_articles_';
  static const String _cacheTimestampPrefix = 'cache_timestamp_';
  static const Duration _cacheExpiry = Duration(
    hours: 1,
  ); // Cache expires after 1 hour

  // ==============================================================
  // Reactive State Variables
  // ==============================================================
  final isLoading = true.obs;
  final isRefreshing = false.obs;
  final selectedCategory = 'general'.obs;

  // ==============================================================
  // Categories (for UI Tabs or Dropdown)
  // ==============================================================
  List<Map<String, String>> getCategories() {
    final s = S.current;
    return [
      {'label': s.general, 'value': 'general'},
      {'label': s.sports, 'value': 'sports'},
      {'label': s.technology, 'value': 'technology'},
      {'label': s.business, 'value': 'business'},
      {'label': s.health, 'value': 'health'},
      {'label': s.science, 'value': 'science'},
      {'label': s.entertainment, 'value': 'entertainment'},
    ];
  }

  // ==============================================================
  // News Articles List (Domain Entity)
  // ==============================================================
  final articles = <Article>[].obs;

  // ==============================================================
  // Controller Initialization
  // Manual dependency injection for now (could use Get.put later)
  // ==============================================================
  @override
  void onInit() {
    super.onInit();

    // Setup Dio + API client
    final dio = Dio();
    final apiClient = ApiClient(dio);

    // Initialize all data sources
    final gnews = GNewsRemoteDataSourceImpl(apiClient: apiClient);
    final newsapi = NewsApiRemoteDataSourceImpl(apiClient: apiClient);
    final newsdata = NewsDataRemoteDataSourceImpl(apiClient: apiClient);
    final mapper = ArticleMapper();

    // Build repository with dependencies
    _newsRepository = NewsRepositoryImpl(
      gNewsDataSource: gnews,
      newsApiDataSource: newsapi,
      newsDataDataSource: newsdata,
      mapper: mapper,
    );

    // Load cached data first, then fetch fresh data
    loadCachedNews();
    fetchNews();
  }

  // ==============================================================
  // Load Cached News by Category
  // Loads from GetStorage cache if available and not expired
  // ==============================================================
  void loadCachedNews() {
    try {
      final String currentCategory = selectedCategory.value;
      final cacheKey = '$_cachePrefix$currentCategory';
      final timestampKey = '$_cacheTimestampPrefix$currentCategory';

      final cachedData = _storage.read<List>(cacheKey);
      final cacheTimestamp = _storage.read<String>(timestampKey);

      if (cachedData != null && cacheTimestamp != null) {
        final cachedTime = DateTime.parse(cacheTimestamp);
        final now = DateTime.now();

        // Check if cache is still valid (not expired)
        if (now.difference(cachedTime) < _cacheExpiry) {
          articles.value = cachedData
              .map(
                (item) => Article(
                  id: item['id'] as String,
                  title: item['title'] as String,
                  description: item['description'] as String?,
                  imageUrl: item['imageUrl'] as String?,
                  sourceName: item['sourceName'] as String,
                  articleUrl: item['articleUrl'] as String,
                  publishedAt: DateTime.parse(item['publishedAt'] as String),
                ),
              )
              .toList();
          isLoading(false);
        }
      }
    } catch (e) {
      // If cache loading fails, just continue to fetch from API
      print('Error loading cached news: $e');
    }
  }

  // ==============================================================
  // Save News to Cache
  // Saves articles to GetStorage with timestamp
  // ==============================================================
  void _saveNewsToCache(String category, List<Article> articlesToCache) {
    try {
      final cacheKey = '$_cachePrefix$category';
      final timestampKey = '$_cacheTimestampPrefix$category';

      final toSave = articlesToCache
          .map(
            (article) => {
              'id': article.id,
              'title': article.title,
              'description': article.description,
              'imageUrl': article.imageUrl,
              'sourceName': article.sourceName,
              'articleUrl': article.articleUrl,
              'publishedAt': article.publishedAt.toIso8601String(),
            },
          )
          .toList();

      _storage.write(cacheKey, toSave);
      _storage.write(timestampKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('Error saving news to cache: $e');
    }
  }

  // ==============================================================
  // Fetch News by Category
  // Handles loading, API errors, and UI update
  // Uses ErrorHandlerService for unified error handling
  // Caches successful results to GetStorage
  // ==============================================================
  Future<void> fetchNews({bool forceRefresh = false}) async {
    try {
      // Only show loading if not already showing cached data
      if (articles.isEmpty || forceRefresh) {
        isLoading(true);
      } else {
        isRefreshing(true);
      }

      final String currentCategory = selectedCategory.value;

      final fetchedArticles = await _newsRepository.getTopHeadlines(
        category: currentCategory,
      );

      articles.value = fetchedArticles;

      // Cache successful results
      _saveNewsToCache(currentCategory, fetchedArticles);

      // Show success message if we got results (optional - can be removed if too verbose)
      // if (fetchedArticles.isNotEmpty) {
      //   AppLogger.info('Loaded ${fetchedArticles.length} articles');
      // }
    } on ApiException catch (e) {
      // Use ErrorHandlerService for consistent error handling
      ErrorHandlerService.handleError(
        e,
        customMessage: S.current.errorLoadingNews,
      );

      // If API fails and we have cached data, keep showing cached data
      if (articles.isEmpty) {
        loadCachedNews();
      }
    } catch (e) {
      // Handle unexpected errors
      ErrorHandlerService.handleError(
        e,
        customMessage: S.current.anErrorOccurred,
      );

      // If API fails and we have cached data, keep showing cached data
      if (articles.isEmpty) {
        loadCachedNews();
      }
    } finally {
      isLoading(false);
      isRefreshing(false);
    }
  }

  // ==============================================================
  // Change Category and Refresh
  // Loads cached data first, then fetches fresh data
  // ==============================================================
  void changeCategory(String newValue) {
    selectedCategory(newValue);
    // Load cached data for new category first
    loadCachedNews();
    // Then fetch fresh data
    fetchNews();
  }

  // ==============================================================
  // Clear Cache
  // Clears all cached articles (useful for debugging or forced refresh)
  // ==============================================================
  void clearCache() {
    try {
      final categories = getCategories();
      for (var category in categories) {
        final categoryValue = category['value']!;
        _storage.remove('$_cachePrefix$categoryValue');
        _storage.remove('$_cacheTimestampPrefix$categoryValue');
      }
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
}
