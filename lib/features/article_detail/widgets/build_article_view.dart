import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mega_news_app/core/constants/app_const.dart';
import 'package:mega_news_app/core/theme/app_theme_helper.dart';
import 'package:mega_news_app/features/article_detail/controller/article_detail_controller.dart';
import 'package:timeago/timeago.dart' as timeago;

Widget buildArticleView(
  BuildContext context,
  AppThemeHelper theme,
  ArticleDetailController controller,
  final article,
) {
  return Scaffold(
    backgroundColor: theme.colorScheme.surface,
    body: Obx(() {
      final dynamicColor =
          controller.vibrantColor.value ?? theme.colorScheme.primary;
      final dynamicTextColor =
          controller.vibrantTextColor.value ?? Colors.white;

      return CustomScrollView(
        slivers: [
          // 🔹 AppBar
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            stretch: true,
            elevation: 0,
            backgroundColor: theme.background,
            title: Text(
              article!.sourceName,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                shadows: const [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 4,
                    color: Colors.black38,
                  ),
                ],
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: article!.id,
                    child: Image.network(
                      article!.imageUrl ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.broken_image,
                          size: 60,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black54,
                          Colors.transparent,
                          Colors.black45,
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🔹 محتوى المقال
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    dynamicColor.withOpacity(0.1),
                    theme.colorScheme.surface,
                  ],
                  stops: const [0.0, 0.4],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article!.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    AppConst.h12,
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey,
                        ),
                        AppConst.h8,
                        Text(
                          '${timeago.format(article!.publishedAt)}  •  ${article!.sourceName}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    AppConst.h20,
                    Text(
                      article!.description ??
                          'No content available for this article.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        height: 1.6,
                        color: theme.colorScheme.onSurface.withOpacity(0.9),
                      ),
                    ),
                    AppConst.h24,
                    Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: dynamicColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: dynamicColor.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Read Full Story'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: dynamicTextColor,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(fontSize: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: controller.openArticleLink,
                        ),
                      ),
                    ),
                    AppConst.h32,
                    AppConst.h12,
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }),
  );
}
