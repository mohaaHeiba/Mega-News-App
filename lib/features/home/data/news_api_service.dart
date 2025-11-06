import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mega_news_app/features/home/domain/entities/article.dart';

class NewsApiService {
  static const String _baseUrl = 'https://newsapi.org/v2';
  static const String _apiKey = '32a4184658214dd8aeffec62c2ac5717';

  Future<List<Article>> fetchTopHeadlines({String category = 'general'}) async {
    final url = Uri.parse(
      '$_baseUrl/top-headlines?country=us&category=$category&apiKey=$_apiKey',
    );

    final res = await http.get(url);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final List articles = data['articles'] ?? [];
      return articles
          .map<Article>(
            (a) => Article.fromMap({
              'title': a['title'] ?? 'No Title',
              'summary': a['description'] ?? '',
              'image': a['urlToImage'] ?? 'https://picsum.photos/600/350',
              'time': a['publishedAt'] ?? '',
            }),
          )
          .toList();
    } else {
      throw Exception('Failed to load news');
    }
  }
}
