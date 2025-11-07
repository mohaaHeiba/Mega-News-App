// To parse this JSON data, do
//
//     final newsapiResponseModel = newsapiResponseModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

NewsapiResponseModel newsapiResponseModelFromJson(String str) =>
    NewsapiResponseModel.fromJson(json.decode(str));

String newsapiResponseModelToJson(NewsapiResponseModel data) =>
    json.encode(data.toJson());

class NewsapiResponseModel {
  final String status;
  final int totalResults;
  final List<NewsApiArticleModel> articles; // <-- تم التعديل هنا

  NewsapiResponseModel({
    required this.status,
    required this.totalResults,
    required this.articles,
  });

  factory NewsapiResponseModel.fromJson(Map<String, dynamic> json) =>
      NewsapiResponseModel(
        status: json["status"],
        totalResults: json["totalResults"],
        articles: List<NewsApiArticleModel>.from(
          // <-- تم التعديل هنا
          json["articles"].map(
            (x) => NewsApiArticleModel.fromJson(x),
          ), // <-- تم التعديل هنا
        ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "totalResults": totalResults,
    "articles": List<dynamic>.from(articles.map((x) => x.toJson())),
  };
}

class NewsApiArticleModel {
  // <-- تم التعديل هنا
  final NewsApiSourceModel source; // <-- تم التعديل هنا
  final String?
  author; // ملحوظة: خليت author و description و content يقبلوا null
  final String title;
  final String? description;
  final String url;
  final String? urlToImage;
  final DateTime publishedAt;
  final String? content;

  NewsApiArticleModel({
    // <-- تم التعديل هنا
    required this.source,
    this.author,
    required this.title,
    this.description,
    required this.url,
    this.urlToImage,
    required this.publishedAt,
    this.content,
  });

  factory NewsApiArticleModel.fromJson(Map<String, dynamic> json) =>
      NewsApiArticleModel(
        // <-- تم التعديل هنا
        source: NewsApiSourceModel.fromJson(
          json["source"],
        ), // <-- تم التعديل هنا
        author: json["author"],
        title: json["title"] ?? "No Title", // احتياطي لو العنوان null
        description: json["description"],
        url: json["url"],
        urlToImage: json["urlToImage"],
        publishedAt: DateTime.parse(json["publishedAt"]),
        content: json["content"],
      );

  Map<String, dynamic> toJson() => {
    "source": source.toJson(),
    "author": author,
    "title": title,
    "description": description,
    "url": url,
    "urlToImage": urlToImage,
    "publishedAt": publishedAt.toIso8601String(),
    "content": content,
  };
}

class NewsApiSourceModel {
  // <-- تم التعديل هنا
  final String? id; // خليتها تقبل null لأنها ساعات بتبقى null
  final String name;

  NewsApiSourceModel({this.id, required this.name}); // <-- تم التعديل هنا

  factory NewsApiSourceModel.fromJson(
    Map<String, dynamic> json,
  ) => // <-- تم التعديل هنا
  NewsApiSourceModel(
    id: json["id"],
    name: json["name"],
  ); // <-- تم التعديل هنا

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}
