import 'package:mega_news_app/features/news/data/model/gnews_response_model.dart';
import 'package:mega_news_app/features/news/data/model/newsapi_response_model.dart';
import 'package:mega_news_app/features/news/data/model/newsdata_response_model.dart';
import 'package:mega_news_app/features/news/domain/entities/article.dart';

class ArticleMapper {
  // =============== convert Genew ==================

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

  // =============== convert NewsApi ==================
  Article fromNewsApiModel(NewsApiArticleModel model) {
    return Article(
      id: '${model.source.name}_${model.url}',
      title: model.title,
      description: model.description,
      imageUrl: model.urlToImage,
      sourceName: model.source.name,
      articleUrl: model.url,
      publishedAt: model.publishedAt,
    );
  }

  // =============== convert NewsData ==================
  Article fromNewsDataModel(NewsDataArticleModel model) {
    return Article(
      id: '${model.sourceName}_${model.link}',
      title: model.title,
      description: model.description,
      imageUrl: model.imageUrl,
      sourceName: model.sourceName,
      articleUrl: model.link,
      publishedAt: model.pubDate,
    );
  }
}
