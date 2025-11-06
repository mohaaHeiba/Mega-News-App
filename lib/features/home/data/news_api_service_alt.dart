import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../domain/entities/article.dart';
import 'news_data_source.dart';

/// Alternate HTTP news service using The Guardian Open Platform.
///
/// This uses the `GUARDIAN_API_KEY` value from the environment (`.env`) if
/// provided. If the key is missing the service returns an empty list so the
/// repository can fall back to other sources.
class NewsApiAltService implements NewsDataSource {
  static const String _baseUrl = 'https://content.guardianapis.com';

  @override
  Future<List<Article>> fetchTopHeadlines({String category = 'general'}) async {
    final key =
        'https://content.guardianapis.com/search?api-key=4febd1cc-5775-4307-878e-0e5ef620ffff' ??
        '';
    if (key.isEmpty) return <Article>[];

    // The Guardian uses 'section' for category filtering; fall back to 'news'.
    final section = (category.isEmpty || category == 'general')
        ? 'news'
        : category;
    final url = Uri.parse(
      '$_baseUrl/search?section=$section&show-fields=thumbnail,trailText&api-key=$key',
    );

    final res = await http.get(url);
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as Map<String, dynamic>;
      final List items = (data['response']?['results']) ?? [];
      return items
          .map<Article>(
            (a) => Article.fromMap({
              'title': a['webTitle'] ?? 'No Title',
              'summary': a['fields']?['trailText'] ?? '',
              'image':
                  a['fields']?['thumbnail'] ?? 'https://picsum.photos/600/350',
              'time': a['webPublicationDate'] ?? '',
            }),
          )
          .toList();
    }

    // on error return empty so other sources can be used
    return <Article>[];
  }
}
