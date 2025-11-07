// lib/features/news/presentation/controllers/home_controller.dart

import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:mega_news_app/core/errors/api_exception.dart';
import 'package:mega_news_app/core/network/api_cleint.dart';
import 'package:mega_news_app/core/services/error_handler_service.dart';
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

  // ==============================================================
  // Reactive State Variables
  // ==============================================================
  final isLoading = true.obs;
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

    // Fetch initial data on startup
    fetchNews();
  }

  // ==============================================================
  // Fetch News by Category
  // Handles loading, API errors, and UI update
  // Uses ErrorHandlerService for unified error handling
  // ==============================================================
  Future<void> fetchNews() async {
    try {
      isLoading(true);
      articles.clear();

      final String currentCategory = selectedCategory.value;

      final fetchedArticles = await _newsRepository.getTopHeadlines(
        category: currentCategory,
      );

      articles.value = fetchedArticles;
      
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
    } catch (e) {
      // Handle unexpected errors
      ErrorHandlerService.handleError(
        e,
        customMessage: S.current.anErrorOccurred,
      );
    } finally {
      isLoading(false);
    }
  }

  // ==============================================================
  // Change Category and Refresh
  // ==============================================================
  void changeCategory(String newValue) {
    selectedCategory(newValue);
    fetchNews();
  }
}
