// ... (imports) ...

// ... (imports) ...

import 'package:mega_news_app/features/news/domain/entities/article.dart';

abstract class INewsRepository {
  // --- 🚀 التعديل هنا ---
  Future<List<Article>> getTopHeadlines({required String category});
  // --- نهاية التعديل ---

  Future<List<Article>> searchNews(String query);
}
