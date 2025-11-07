import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mega_news_app/features/article_detail/pages/article_detail_page.dart'
    show ArticleDetailPage;

import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:mega_news_app/core/errors/api_exception.dart';
import 'package:mega_news_app/core/network/api_cleint.dart';
import 'package:mega_news_app/core/services/error_handler_service.dart';
import 'package:mega_news_app/core/utils/logger.dart';
import 'package:mega_news_app/generated/l10n.dart';

// 1. استدعاء كل الـ classes اللي عملناها (Data Layer)
import 'package:mega_news_app/features/news/data/datasources/gnews_remote_datasource.dart';
import 'package:mega_news_app/features/news/data/datasources/newsapi_remote_datasource.dart';
import 'package:mega_news_app/features/news/data/datasources/newsdata_remote_datasource.dart';
import 'package:mega_news_app/features/news/data/mappers/article_mapper.dart';

// 2. استدعاء الـ Interface والـ Entity (Domain Layer)
import 'package:mega_news_app/features/news/domain/entities/article.dart';
import 'package:mega_news_app/features/news/domain/repositories/i_news_repository.dart';
import 'package:mega_news_app/features/news/domain/repositories/news_repository_impl.dart';

// --- 🚀 3. استدعاء لوجيك Gemini ---
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:mega_news_app/features/gemini/data/datasources/gemini_remote_datasource.dart';
import 'package:mega_news_app/features/gemini/data/repositories/gemini_repository_impl.dart';
import 'package:mega_news_app/features/gemini/domain/usecases/get_ai_summary_usecase.dart';
// --- 🚀 4. استدعاء صفحة التفاصيل ---

// --- (كلاس الـ Debouncer زي ما هو) ---
class Debouncer {
  final int milliseconds;
  Timer? _timer;
  Debouncer({required this.milliseconds});
  run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void cancel() {
    _timer?.cancel();
  }
}

// --- كنترولر البحث ---
class SearchController extends GetxController {
  // --- 1. الـ Repositories & UseCases ---
  late final INewsRepository _newsRepository;
  late final GetAiSummaryUseCase
  _getAiSummaryUseCase; // <-- 🚀 5. إضافة الـ UseCase

  // --- 2. الـ State Variables ---
  final isLoading = false.obs;
  final articles = <Article>[].obs;
  final searchQuery = ''.obs;

  // --- 🚀 6. إضافة متغير حالة للـ AI ---
  final isSummarizing = false.obs;
  // --------------------------------

  // ... (Speech-to-Text Variables زي ما هي) ...
  final SpeechToText _speechToText = SpeechToText();
  final isListening = false.obs;
  final textController = TextEditingController();
  bool _speechEnabled = false;
  final _debouncer = Debouncer(milliseconds: 600);

  SearchController() {
    // --- 🚀 7. الـ Dependency Injection اليدوي (ضفنا Gemini) ---
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
    // --- نهاية الـ Injection ---
  }

  // ... (onInit, _onSearchChanged, _initSpeech, startListening, stopListening, _onListeningDone) ...
  // ... (كل الميثودز دي زي ما هي بالظبط) ...
  @override
  void onInit() {
    super.onInit();
    _initSpeech();
    textController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    searchQuery.value = textController.text;
    final query = textController.text.trim();
    if (query.isEmpty) {
      articles.clear();
      isLoading.value = false;
      _debouncer.cancel();
      return;
    }
    if (query.length > 2) {
      isLoading.value = true;
      _debouncer.run(() {
        _performSearch(query);
      });
    }
  }

  void _initSpeech() {
    _speechToText.initialize().then((value) => _speechEnabled = value);
    _speechToText.statusListener = (status) {
      if (status == 'notListening' || status == 'done') {
        _onListeningDone();
      }
    };
  }

  void startListening() {
    if (!_speechEnabled) return;
    textController.clear();
    articles.clear();
    isListening.value = true;
    _speechToText.listen(
      onResult: (result) {
        textController.text = result.recognizedWords;
        textController.selection = TextSelection.fromPosition(
          TextPosition(offset: textController.text.length),
        );
      },
    );
  }

  void stopListening() {
    _speechToText.stop();
    _onListeningDone();
  }

  void _onListeningDone() {
    isListening.value = false;
  }

  Future<void> _performSearch(String query) async {
    try {
      articles.clear();
      final fetchedArticles = await _newsRepository.searchNews(query);
      articles.value = fetchedArticles;
      
      // Show message if no results found
      if (fetchedArticles.isEmpty) {
        final s = S.current;
        Get.snackbar(
          s.noResults,
          'Try a different search term',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      } else {
        AppLogger.info('Found ${fetchedArticles.length} articles');
      }
    } on ApiException catch (e) {
      // Use ErrorHandlerService for consistent error handling
      ErrorHandlerService.handleError(
        e,
        customMessage: S.current.errorSearching,
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

  // --- 🚀 8. ميثود طلب التلخيص (النضيفة) ---
  Future<void> summarizeSearchResults() async {
    if (articles.isEmpty) {
      final s = S.current;
      Get.snackbar(
        s.noResults,
        s.searchForArticlesFirst,
      );
      return;
    }

    isSummarizing.value = true;
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      // 🚀 9. بنكلم الـ UseCase ونبعتله النتايج الحالية
      final summary = await _getAiSummaryUseCase.call(
        topic: searchQuery.value,
        articles: articles.toList(),
      );

      Get.back(); // إغلاق شاشة التحميل

      // 🚀 10. بنبعت الملخص لصفحة التفاصيل (في وضع الملخص)
      Get.to(
        () => ArticleDetailPage(
          topic: searchQuery.value, // بنبعت الموضوع
          summary: summary, // بنبعت الملخص
          article: null, // مش بنبعت مقال
        ),
      );
    } on ApiException catch (e) {
      final s = S.current;
      Get.back();
      Get.snackbar(s.summarizationFailed, e.message);
    } catch (e) {
      final s = S.current;
      Get.back();
      Get.snackbar(s.summarizationFailed, e.toString());
    } finally {
      isSummarizing.value = false;
    }
  }

  @override
  void onClose() {
    textController.removeListener(_onSearchChanged);
    textController.dispose();
    _debouncer.cancel();
    _speechToText.stop();
    super.onClose();
  }
}
