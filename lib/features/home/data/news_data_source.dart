import '../domain/entities/article.dart';

/// Simple interface for a news data source.
abstract class NewsDataSource {
  Future<List<Article>> fetchTopHeadlines({String category = 'general'});
}
