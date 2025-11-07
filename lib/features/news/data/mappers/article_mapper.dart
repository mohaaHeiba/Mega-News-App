// lib/features/news/data/mappers/article_mapper.dart

import 'package:mega_news_app/features/news/data/model/gnews_response_model.dart';
import 'package:mega_news_app/features/news/data/model/newsapi_response_model.dart';
import 'package:mega_news_app/features/news/data/model/newsdata_response_model.dart';
import 'package:mega_news_app/features/news/domain/entities/article.dart';

class ArticleMapper {
  // --- 1. ميثود تحويل GNews ---
  Article fromGNewsModel(GNewsArticleModel model) {
    return Article(
      id: '${model.source.name}_${model.url}',
      title: model.title,
      description: model.description,
      imageUrl: model.image,
      sourceName: model.source.name,
      articleUrl: model.url,
      publishedAt: model.publishedAt,
    );
  }

  // --- 2. ميثود تحويل NewsAPI ---
  Article fromNewsApiModel(NewsApiArticleModel model) {
    return Article(
      id: '${model.source.name}_${model.url}',
      title: model.title,
      description: model.description,
      imageUrl: model.urlToImage, // <-- هنا بنوحد الأسماء
      sourceName: model.source.name,
      articleUrl: model.url,
      publishedAt: model.publishedAt,
    );
  }

  // --- 3. ميثود تحويل NewsData ---
  Article fromNewsDataModel(NewsDataArticleModel model) {
    return Article(
      id: '${model.sourceName}_${model.link}',
      title: model.title,
      description: model.description,
      imageUrl: model.imageUrl, // <-- هنا بنوحد الأسماء
      sourceName: model.sourceName,
      articleUrl: model.link, // <-- هنا بنوحد الأسماء
      publishedAt: model.pubDate,
    );
  }
}
