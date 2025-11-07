import 'package:get/get.dart';
import 'package:dio/dio.dart'; // 1. استدعاء Dio
import 'package:mega_news_app/core/errors/api_exception.dart';
import 'package:mega_news_app/core/network/api_cleint.dart';

// 2. استدعاء كل الـ classes اللي عملناها (Data Layer)
import 'package:mega_news_app/features/news/data/datasources/gnews_remote_datasource.dart';
import 'package:mega_news_app/features/news/data/datasources/newsapi_remote_datasource.dart';
import 'package:mega_news_app/features/news/data/datasources/newsdata_remote_datasource.dart';
import 'package:mega_news_app/features/news/data/mappers/article_mapper.dart';

// 3. استدعاء الـ Interface والـ Entity (Domain Layer)
import 'package:mega_news_app/features/news/domain/entities/article.dart';
import 'package:mega_news_app/features/news/domain/repositories/i_news_repository.dart';
import 'package:mega_news_app/features/news/domain/repositories/news_repository_impl.dart';

class HomeController extends GetxController {
  // --- 1. الـ Repository ---
  late final INewsRepository _newsRepository;

  // --- 2. الـ State Variables (زي ما هي) ---
  final isLoading = true.obs;
  final selectedCategory = 'general'.obs;

  // --- 🚀 التعديل هنا ---
  final categories = const [
    {'label': 'General', 'value': 'general'},
    {'label': 'Sports', 'value': 'sports'},
    {'label': 'Technology', 'value': 'technology'},
    {'label': 'Business', 'value': 'business'},
    {'label': 'Health', 'value': 'health'},
    {'label': 'Science', 'value': 'science'}, // <-- إضافة
    {'label': 'Entertainment', 'value': 'entertainment'}, // <-- إضافة
  ];
  // --- نهاية التعديل ---

  // 4. Articles List (بيستخدم الـ Entity النضيفة بتاعتنا)
  final articles = <Article>[].obs;

  @override
  void onInit() {
    super.onInit();

    // --- 5. الـ Dependency Injection اليدوي ---
    final dio = Dio();
    final apiClient = ApiClient(dio);

    final gnews = GNewsRemoteDataSourceImpl(apiClient: apiClient);
    final newsapi = NewsApiRemoteDataSourceImpl(apiClient: apiClient);
    final newsdata = NewsDataRemoteDataSourceImpl(apiClient: apiClient);
    final mapper = ArticleMapper();

    _newsRepository = NewsRepositoryImpl(
      gNewsDataSource: gnews,
      newsApiDataSource: newsapi,
      newsDataDataSource: newsdata,
      mapper: mapper,
    );
    // --- نهاية الـ Injection ---

    fetchNews(); // Load initial data
  }

  // --- 6. Methods (تم تعديلها) ---
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

  void changeCategory(String newValue) {
    selectedCategory(newValue);
    fetchNews();
  }
}
