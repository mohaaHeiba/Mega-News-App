import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../domain/entities/article.dart';
import 'news_data_source.dart';

/// GNews service wrapper. Reads `GNEWS_API_KEY` from the environment (.env).
/// If the key is missing the service returns an empty list so repository can
/// continue with other sources.
class NewsGNewsService implements NewsDataSource {
  static const String _baseUrl = 'https://gnews.io/api/v4';

  @override
  Future<List<Article>> fetchTopHeadlines({String category = 'general'}) async {
    final key = '0c5880b3e409e7fc23abf33424b3e8af' ?? '';
    if (key.isEmpty) return <Article>[];

    // Map our category to a 'topic' parameter where possible.
    final topic = (category.isEmpty || category == 'general')
        ? 'general'
        : category;
    final url = Uri.parse(
      '$_baseUrl/top-headlines?topic=$topic&lang=en&token=$key',
    );

    final res = await http.get(url);
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as Map<String, dynamic>;
      final List items = data['articles'] ?? [];
      return items
          .map<Article>(
            (a) => Article.fromMap({
              'title': a['title'] ?? 'No Title',
              'summary': a['description'] ?? '',
              'image': a['image'] ?? 'https://picsum.photos/600/350',
              'time': a['publishedAt'] ?? '',
            }),
          )
          .toList();
    }

    return <Article>[];
  }
}
