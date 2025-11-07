// lib/features/news/data/repositories/news_repository_impl.dart

import 'package:mega_news_app/features/news/data/datasources/gnews_remote_datasource.dart';
import 'package:mega_news_app/features/news/data/datasources/newsapi_remote_datasource.dart';
import 'package:mega_news_app/features/news/data/datasources/newsdata_remote_datasource.dart';
import 'package:mega_news_app/features/news/data/mappers/article_mapper.dart';
import 'package:mega_news_app/features/news/data/model/gnews_response_model.dart';
import 'package:mega_news_app/features/news/data/model/newsapi_response_model.dart';
import 'package:mega_news_app/features/news/data/model/newsdata_response_model.dart';
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

  @override
  // --- 1. ميثود جلب الأخبار (بالـ category) ---
  Future<List<Article>> getTopHeadlines({required String category}) async {
    // هنبعت الـ category لكل واحد
    final responses = await Future.wait([
      gNewsDataSource
          .getTopHeadlines(category: category)
          .catchError((_) => <GNewsArticleModel>[]),
      newsApiDataSource
          .getTopHeadlines(category: category)
          .catchError((_) => <NewsApiArticleModel>[]),
      newsDataDataSource
          .getTopHeadlines(category: category)
          .catchError((_) => <NewsDataArticleModel>[]),
    ]);

    // افصل النتايج "الخام"
    final gnewsRaw = responses[0] as List<GNewsArticleModel>;
    final newsApiRaw = responses[1] as List<NewsApiArticleModel>;
    final newsDataRaw = responses[2] as List<NewsDataArticleModel>;

    // استخدم الـ Mapper "لتنضيف" وترجمة كل list
    final gnewsArticles = gnewsRaw.map(mapper.fromGNewsModel).toList();
    final newsApiArticles = newsApiRaw.map(mapper.fromNewsApiModel).toList();
    final newsDataArticles = newsDataRaw.map(mapper.fromNewsDataModel).toList();

    // ادمجهم كلهم في List واحدة
    final allArticles = [
      ...gnewsArticles,
      ...newsApiArticles,
      ...newsDataArticles,
    ];

    // امسح المكرر ورتب
    return _processAndSortArticles(allArticles);
  }

  @override
  // --- 2. ميثود البحث (دي اللي كانت ناقصة) ---
  Future<List<Article>> searchNews(String query) async {
    final responses = await Future.wait([
      gNewsDataSource
          .searchNews(query)
          .catchError((_) => <GNewsArticleModel>[]),
      newsApiDataSource
          .searchNews(query)
          .catchError((_) => <NewsApiArticleModel>[]),
      newsDataDataSource
          .searchNews(query)
          .catchError((_) => <NewsDataArticleModel>[]),
    ]);

    // افصل النتايج "الخام"
    final gnewsRaw = responses[0] as List<GNewsArticleModel>;
    final newsApiRaw = responses[1] as List<NewsApiArticleModel>;
    final newsDataRaw = responses[2] as List<NewsDataArticleModel>;

    // استخدم الـ Mapper "لتنضيف" وترجمة كل list
    final gnewsArticles = gnewsRaw.map(mapper.fromGNewsModel).toList();
    final newsApiArticles = newsApiRaw.map(mapper.fromNewsApiModel).toList();
    final newsDataArticles = newsDataRaw.map(mapper.fromNewsDataModel).toList();

    // ادمجهم كلهم في List واحدة
    final allArticles = [
      ...gnewsArticles,
      ...newsApiArticles,
      ...newsDataArticles,
    ];

    // امسح المكرر ورتب
    return _processAndSortArticles(allArticles);
  }

  /// ميثود خاصة للمعالجة والترتيب
  List<Article> _processAndSortArticles(List<Article> articles) {
    // استخدم Set عشان تمسح المكرر (بناءً على الـ ID اللي عملناه)
    final uniqueArticles = articles.toSet().toList();

    // رتب المقالات من الأحدث للأقدم
    uniqueArticles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    return uniqueArticles;
  }
}
