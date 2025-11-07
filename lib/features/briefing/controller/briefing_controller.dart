import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:mega_news_app/core/errors/api_exception.dart';
import 'package:mega_news_app/core/network/api_cleint.dart';
import 'package:mega_news_app/features/news/data/datasources/gnews_remote_datasource.dart';
import 'package:mega_news_app/features/news/data/datasources/newsapi_remote_datasource.dart';
import 'package:mega_news_app/features/news/data/datasources/newsdata_remote_datasource.dart';
import 'package:mega_news_app/features/news/data/mappers/article_mapper.dart';
import 'package:mega_news_app/features/news/domain/entities/article.dart';
import 'package:mega_news_app/features/news/domain/repositories/i_news_repository.dart';
import 'package:mega_news_app/features/news/domain/repositories/news_repository_impl.dart';
import 'package:mega_news_app/features/gemini/data/datasources/gemini_remote_datasource.dart';
import 'package:mega_news_app/features/gemini/data/repositories/gemini_repository_impl.dart';
import 'package:mega_news_app/features/gemini/domain/repositories/i_gemini_repository.dart';
import 'package:mega_news_app/features/gemini/domain/usecases/get_ai_summary_usecase.dart';

/// (موديل TopicSummary زي ما هو)
class TopicSummary {
  final String topicLabel;
  final String topicValue;
  final IconData icon;
  final String summary;

  TopicSummary({
    required this.topicLabel,
    required this.topicValue,
    required this.icon,
    required this.summary,
  });
}

class AiBriefingController extends GetxController {
  // --- 1. الـ Repositories & UseCases ---
  late final INewsRepository _newsRepository;
  late final GetAiSummaryUseCase _getAiSummaryUseCase;

  // --- 2. الـ State Variables ---
  final isLoading = true.obs;
  final summaries = <TopicSummary>[].obs;

  // --- 🚀 3. حذف متغيرات الفلترة ---
  // final selectedHours = 6.obs;
  // final timeFilters = const [ ... ];
  // --- نهاية الحذف ---

  // --- (الأقسام زي ما هي) ---
  final topicsToBrief = const [
    {'label': 'General', 'value': 'general', 'icon': Icons.public_rounded},
    {'label': 'Sports', 'value': 'sports', 'icon': Icons.sports_soccer_rounded},
    {
      'label': 'Technology',
      'value': 'technology',
      'icon': Icons.computer_rounded,
    },
    {
      'label': 'Business',
      'value': 'business',
      'icon': Icons.business_center_rounded,
    },
    {
      'label': 'Health',
      'value': 'health',
      'icon': Icons.local_hospital_rounded,
    },
    {'label': 'Science', 'value': 'science', 'icon': Icons.science_rounded},
  ];

  // --- (الـ Constructor والـ Injection زي ما هما) ---
  AiBriefingController() {
    // (News)
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
    // (Gemini)
    final gemini = Gemini.instance;
    final geminiDataSource = GeminiRemoteDataSourceImpl(gemini);
    final geminiRepository = GeminiRepositoryImpl(geminiDataSource);
    _getAiSummaryUseCase = GetAiSummaryUseCase(geminiRepository);
  }

  @override
  void onInit() {
    super.onInit();
    fetchBriefings();
  }

  // --- 🚀 4. حذف ميثود changeTimeFilter ---
  // void changeTimeFilter(int hours) { ... }
  // --- نهاية الحذف ---

  /// 5. الميثود الرئيسية: بتجيب كل الملخصات
  Future<void> fetchBriefings() async {
    isLoading(true);
    summaries.clear();

    try {
      final List<Future<TopicSummary>> futures = topicsToBrief.map((topic) {
        return _fetchAndSummarizeTopic(
          topic['label'] as String,
          topic['value'] as String,
          topic['icon'] as IconData,
        );
      }).toList();
      final results = await Future.wait(futures);
      summaries.value = results;
    } catch (e) {
      Get.snackbar('Error', 'Failed to generate briefings: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  /// 6. ميثود مساعدة: بتجيب أخبار موضوع واحد وتلخصه
  Future<TopicSummary> _fetchAndSummarizeTopic(
    String label,
    String value,
    IconData icon,
  ) async {
    try {
      // 7. جيب آخر الأخبار (صفحة 1)
      final articles = await _newsRepository.getTopHeadlines(category: value);

      // --- 🚀 8. حذف لوجيك الفلترة ---
      // final cutoffTime = ...
      // final filteredArticles = ...
      // --- نهاية الحذف ---

      // 9. لو مفيش أخبار (بنستخدم articles)
      if (articles.isEmpty) {
        return TopicSummary(
          topicLabel: label,
          topicValue: value,
          icon: icon,
          // 🚀 10. تعديل رسالة الخطأ
          summary: 'No recent news found to summarize for this topic.',
        );
      }

      // 10. كلم الـ UseCase (بنستخدم articles)
      final summary = await _getAiSummaryUseCase.call(
        topic: label,
        articles: articles.take(10).toList(), // خد أول 10 بس كفاية
      );

      return TopicSummary(
        topicLabel: label,
        topicValue: value,
        icon: icon,
        summary: summary,
      );
    } catch (e) {
      return TopicSummary(
        topicLabel: label,
        topicValue: value,
        icon: icon,
        summary: 'Failed to generate summary: ${e.toString()}',
      );
    }
  }
}
