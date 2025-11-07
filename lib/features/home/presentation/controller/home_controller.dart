// lib/features/news/presentation/controllers/home_controller.dart

import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:mega_news_app/core/errors/api_exception.dart';
import 'package:mega_news_app/core/network/api_cleint.dart';
import 'package:mega_news_app/features/news/data/datasources/gnews_remote_datasource.dart';
import 'package:mega_news_app/features/news/data/datasources/newsapi_remote_datasource.dart';
import 'package:mega_news_app/features/news/data/datasources/newsdata_remote_datasource.dart';
import 'package:mega_news_app/features/news/data/mappers/article_mapper.dart';
import 'package:mega_news_app/features/news/domain/entities/article.dart';
import 'package:mega_news_app/features/news/domain/repositories/i_news_repository.dart';
import 'package:mega_news_app/features/news/domain/repositories/news_repository_impl.dart';

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
  // ategories (for UI Tabs or Dropdown)
  // ==============================================================
  final categories = const [
    {'label': 'General', 'value': 'general'},
    {'label': 'Sports', 'value': 'sports'},
    {'label': 'Technology', 'value': 'technology'},
    {'label': 'Business', 'value': 'business'},
    {'label': 'Health', 'value': 'health'},
    {'label': 'Science', 'value': 'science'},
    {'label': 'Entertainment', 'value': 'entertainment'},
  ];

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
    } on ApiException catch (e) {
      Get.snackbar('Error Loading News', e.message);
    } catch (e) {
      Get.snackbar('An error occurred', e.toString());
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
