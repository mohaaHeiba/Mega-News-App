import '../../domain/entities/article.dart';

abstract class NewsRepository {
  Future<List<Article>> fetchTopHeadlines({String category = 'general'});
}
