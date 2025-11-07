// lib/features/news/presentation/widgets/article_tile.dart
// (ده الملف اللي كان في home/presentation/widgets واتنقل)

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mega_news_app/core/utils/app_context_helper.dart';
import 'package:mega_news_app/features/favorites/presentation/controller/favorites_controller.dart';
import 'package:mega_news_app/features/news/domain/entities/article.dart';
// 1. استدعاء Timeago
// 2. استدعاء صفحة التفاصيل من مكانها الجديد
import 'package:mega_news_app/features/article_detail/pages/article_detail_page.dart';
import 'package:timeago/timeago.dart' as timeago;

class ArticleTile extends StatelessWidget {
  final Article article;
  const ArticleTile({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final favoritesController = Get.find<FavoritesController>();
    final helper = AppContextHelper(context);
    
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Get.to(() => ArticleDetailPage(article: article));
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Hero(
                  // 3. تعديل الـ Tag
                  tag: article.id,
                  child: Image.network(
                    // 4. تعديل الـ Image
                    article.imageUrl ?? '', // Handle null image
                    width: 110,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (context, _, __) => Container(
                      width: 110,
                      height: 72,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      // 5. تعديل الـ Summary
                      article.description ?? '', // Handle null description
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          // 6. تعديل الـ Time
                          timeago.format(article.publishedAt),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Favorite Button
              Obx(
                () => IconButton(
                  icon: Icon(
                    favoritesController.isFavorite(article)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: favoritesController.isFavorite(article)
                        ? Colors.red
                        : Colors.grey,
                    size: 24,
                  ),
                  onPressed: () {
                    favoritesController.toggleFavorite(article);
                  },
                  tooltip: favoritesController.isFavorite(article)
                      ? helper.s.removeFromFavorites
                      : helper.s.addToFavorites,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
