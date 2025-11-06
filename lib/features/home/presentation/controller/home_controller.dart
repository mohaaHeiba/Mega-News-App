import 'package:get/get.dart';
import 'package:mega_news_app/features/home/data/news_api_service.dart';
import 'package:mega_news_app/features/home/domain/entities/article.dart';

class HomeController extends GetxController {
  final NewsApiService _newsApi = NewsApiService();

  var articles = <Article>[].obs;
  var isLoading = false.obs;
  var selectedCategory = 'general'.obs;

  final categories = [
    {'label': 'All', 'value': 'general'},
    {'label': 'Politics', 'value': 'politics'},
    {'label': 'Business', 'value': 'business'},
    {'label': 'Technology', 'value': 'technology'},
    {'label': 'Sports', 'value': 'sports'},
    {'label': 'Entertainment', 'value': 'entertainment'},
  ];

  @override
  void onInit() {
    super.onInit();
    fetchNews();
  }

  Future<void> fetchNews() async {
    try {
      isLoading.value = true;
      articles.value = await _newsApi.fetchTopHeadlines(
        category: selectedCategory.value,
      );
    } catch (e) {
      print('Error fetching news: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void changeCategory(String newCategory) {
    selectedCategory.value = newCategory;
    fetchNews();
  }
}
