import '../domain/entities/article.dart';
import 'news_data_source.dart';
import '../domain/repositories/news_repository.dart';

/// Aggregates multiple NewsDataSource instances, queries them in parallel,
/// merges and deduplicates results.
class NewsRepositoryImpl implements NewsRepository {
  final List<NewsDataSource> sources;

  NewsRepositoryImpl(this.sources);

  @override
  Future<List<Article>> fetchTopHeadlines({String category = 'general'}) async {
    // run all sources in parallel and collect results; if one fails, proceed with others
    final futures = sources.map(
      (s) => s
          .fetchTopHeadlines(category: category)
          .catchError((_) => <Article>[]),
    );
    final results = await Future.wait(futures);

    // flatten
    final all = results.expand((r) => r).toList();

    // deduplicate by title (simple heuristic)
    final seen = <String>{};
    final deduped = <Article>[];
    for (final a in all) {
      final key = a.title.trim();
      if (key.isEmpty) continue;
      if (!seen.contains(key)) {
        seen.add(key);
        deduped.add(a);
      }
    }

    // sort by time desc if possible
    deduped.sort((a, b) {
      try {
        final da =
            DateTime.tryParse(a.time) ?? DateTime.fromMillisecondsSinceEpoch(0);
        final db =
            DateTime.tryParse(b.time) ?? DateTime.fromMillisecondsSinceEpoch(0);
        return db.compareTo(da);
      } catch (_) {
        return 0;
      }
    });

    return deduped;
  }
}
