import 'package:mega_news_app/features/news/domain/entities/article.dart';

abstract class INewsRepository {
  Future<List<Article>> getTopHeadlines({required String category});

  Future<List<Article>> searchNews(String query);
}
