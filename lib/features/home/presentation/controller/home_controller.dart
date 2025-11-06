import 'package:get/get.dart';
import 'package:mega_news_app/features/home/data/news_api_service.dart';
import 'package:mega_news_app/features/home/data/news_api_service_alt.dart';
import 'package:mega_news_app/features/home/data/news_gnews_service.dart';
import 'package:mega_news_app/features/home/data/gemini_remote_data_source.dart';
import 'package:mega_news_app/features/home/data/news_repository_impl.dart';
import 'package:mega_news_app/features/home/domain/entities/article.dart';

class HomeController extends GetxController {
  late final NewsRepositoryImpl _repo;

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
    // compose multiple data sources
    _repo = NewsRepositoryImpl([
      NewsApiService(),
      NewsApiAltService(),
      NewsGNewsService(),
    ]);
    _gemini = GeminiRemoteDataSource();
    fetchNews();
  }

  late final GeminiRemoteDataSource _gemini;
  var summary = ''.obs;
  var isSummarizing = false.obs;

  Future<void> fetchNews() async {
    try {
      isLoading.value = true;
      articles.value = await _repo.fetchTopHeadlines(
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

  /// Generate a summary for the current category over the last [hours] hours.
  Future<void> summarizeCategory({int hours = 24}) async {
    try {
      isSummarizing.value = true;
      final cat = selectedCategory.value;
      final prompt = _buildPrompt(cat, hours, articles);
      final out = await _gemini.generateSummary(prompt);
      summary.value = out;
    } catch (e) {
      summary.value = 'Failed to summarize: $e';
    } finally {
      isSummarizing.value = false;
    }
  }

  String _buildPrompt(String category, int hours, List<Article> items) {
    final buffer = StringBuffer();
    buffer.writeln(
      'Summarize the most important developments in the $category category over the last $hours hours.',
    );
    buffer.writeln(
      'Provide a concise headline-style summary (3-6 bullets) and a short paragraph explanation for each bullet.',
    );
    buffer.writeln('Here are recent article headlines and summaries:');
    for (final a in items) {
      buffer.writeln('- ${a.title}: ${a.summary}');
    }
    buffer.writeln('Keep it short and neutral.');
    return buffer.toString();
  }
}
