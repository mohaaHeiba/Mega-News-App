import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:speech_to_text/speech_to_text.dart'; // 1. استدعاء مكتبة الصوت
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

class SearchController extends GetxController {
  // --- 1. الـ Repository ---
  late final INewsRepository _newsRepository;

  // --- 2. الـ State Variables ---
  final isLoading = false.obs;
  final articles = <Article>[].obs;
  final _searchQuery = ''.obs;

  // --- 3. متغيرات الـ Speech-to-Text ---
  final SpeechToText _speechToText = SpeechToText();
  final isListening = false.obs;
  final textController = TextEditingController();
  bool _speechEnabled = false;

  SearchController() {
    // --- 4. الـ Dependency Injection اليدوي ---
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
  }

  @override
  void onInit() {
    super.onInit();
    _initSpeech();

    // --- 5. الـ Debouncer ---
    debounce(_searchQuery, (query) {
      if (query.isNotEmpty && query.length > 2) {
        _performSearch(query);
      } else if (query.isEmpty) {
        articles.clear();
      }
    }, time: const Duration(milliseconds: 600));

    // 6. ربط الـ textController بالـ debouncer
    textController.addListener(() {
      _searchQuery.value = textController.text;
    });
  }

  /// 7. ميثود تجهيز المايك (تم تعديلها)
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();

    // --- 🚀 8. التعديل هنا: بنعرف المراقب مرة واحدة ---
    _speechToText.statusListener = (status) {
      // (status) بيدينا الحالة الحالية زي 'listening', 'notListening', 'done'
      if (status == 'notListening' || status == 'done') {
        _onListeningDone();
      }
    };
    // --- نهاية التعديل ---
  }

  /// 9. ميثود بدء الاستماع (تم تعديلها)
  void startListening() async {
    if (!_speechEnabled) return;

    // امسح الكلام القديم أول ما اليوزر يدوس
    textController.clear();
    articles.clear();
    isListening.value = true;

    await _speechToText.listen(
      onResult: (result) {
        textController.text = result.recognizedWords;
        textController.selection = TextSelection.fromPosition(
          TextPosition(offset: textController.text.length),
        );
      },
      // --- 🚀 10. التعديل هنا: شيلنا الباراميتر الغلط ---
      // (مبقناش محتاجين statusCallback هنا لأننا عرفناه فوق)
    );
  }

  /// 10. ميثود إيقاف الاستماع (لو اليوزر داس بنفسه)
  void stopListening() async {
    await _speechToText.stop();
    _onListeningDone(); // _onListeningDone هيتنفذ مرتين (مرة من stop ومرة من statusListener)، بس ده عادي ومش هيأثر
  }

  /// 11. ميثود موحدة لإنهاء الاستماع
  void _onListeningDone() {
    isListening.value = false;
  }

  /// 12. الميثود اللي بتجيب الداتا فعلاً
  Future<void> _performSearch(String query) async {
    try {
      isLoading(true);
      articles.clear();
      final fetchedArticles = await _newsRepository.searchNews(query);
      articles.value = fetchedArticles;
    } on ApiException catch (e) {
      Get.snackbar('Error Searching', e.message);
    } catch (e) {
      Get.snackbar('An error occurred', e.toString());
    } finally {
      isLoading(false);
    }
  }

  // 13. بنمسح الـ controller لما الصفحة تتقفل
  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}
