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

  // ==============================================================
  // Fetch top headlines by category
  // Combines results from all APIs, maps, deduplicates, and sorts
  // ==============================================================
  @override
  Future<List<Article>> getTopHeadlines({required String category}) async {
    // Fetch data from all sources in parallel
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

    // Extract raw lists
    final gnewsRaw = responses[0] as List<GNewsArticleModel>;
    final newsApiRaw = responses[1] as List<NewsApiArticleModel>;
    final newsDataRaw = responses[2] as List<NewsDataArticleModel>;

    // Map raw data to unified Article entities
    final gnewsArticles = gnewsRaw.map(mapper.fromGNewsModel).toList();
    final newsApiArticles = newsApiRaw.map(mapper.fromNewsApiModel).toList();
    final newsDataArticles = newsDataRaw.map(mapper.fromNewsDataModel).toList();

    // Merge all lists
    final allArticles = [
      ...gnewsArticles,
      ...newsApiArticles,
      ...newsDataArticles,
    ];

    // Deduplicate & sort by date
    return _processAndSortArticles(allArticles);
  }

  // ==============================================================
  // Search news by keyword
  // Performs multi-source search, maps, merges, and sorts
  // ==============================================================
  @override
  Future<List<Article>> searchNews(String query) async {
    // Fetch data from all sources in parallel
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

    // Extract raw lists
    final gnewsRaw = responses[0] as List<GNewsArticleModel>;
    final newsApiRaw = responses[1] as List<NewsApiArticleModel>;
    final newsDataRaw = responses[2] as List<NewsDataArticleModel>;

    // Map raw data to unified Article entities
    final gnewsArticles = gnewsRaw.map(mapper.fromGNewsModel).toList();
    final newsApiArticles = newsApiRaw.map(mapper.fromNewsApiModel).toList();
    final newsDataArticles = newsDataRaw.map(mapper.fromNewsDataModel).toList();

    // Merge all lists
    final allArticles = [
      ...gnewsArticles,
      ...newsApiArticles,
      ...newsDataArticles,
    ];

    // Deduplicate & sort by date
    return _processAndSortArticles(allArticles);
  }

  // ==============================================================
  // Private helper: remove duplicates & sort by newest first
  // ==============================================================
  List<Article> _processAndSortArticles(List<Article> articles) {
    // Remove duplicates based on article ID
    final uniqueArticles = articles.toSet().toList();

    // Sort by publish date (descending)
    uniqueArticles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    return uniqueArticles;
  }
}
