import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mega_news_app/core/theme/app_theme_helper.dart';
import 'package:mega_news_app/features/article_detail/controller/article_detail_controller.dart';
import 'package:mega_news_app/features/article_detail/widgets/build_article_view.dart';
import 'package:mega_news_app/features/article_detail/widgets/build_summary_view.dart';
import 'package:mega_news_app/features/news/domain/entities/article.dart';

class ArticleDetailPage extends StatelessWidget {
  final Article? article;
  final String? topic;
  final String? summary;

  const ArticleDetailPage({super.key, this.article, this.topic, this.summary})
    : assert(article != null || (topic != null && summary != null));
  // ------------------------------------

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ArticleDetailController(article));
    final theme = AppThemeHelper(context);

    final bool isSummaryMode = article == null;

    if (isSummaryMode) {
      return buildSummaryView(context, theme, topic, summary);
    } else {
      return buildArticleView(context, theme, controller, article);
    }
  }
}
