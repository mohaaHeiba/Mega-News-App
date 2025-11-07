// lib/features/home/presentation/widgets/slider/FeaturedArticle.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mega_news_app/features/news/domain/entities/article.dart';
// 1. استدعاء صفحة التفاصيل من مكانها الجديد
import 'package:mega_news_app/features/article_detail/presentation/pages/article_detail_page.dart';

class FeaturedArticle extends StatelessWidget {
  final Article article;
  const FeaturedArticle({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        Get.to(() => ArticleDetailPage(article: article));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        height: 200,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 2. إضافة Hero
            Hero(
              tag: article.id,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  // 3. تعديل الـ Image
                  article.imageUrl ?? '', // Handle null
                  fit: BoxFit.cover,
                  errorBuilder: (context, _, __) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            ),
            // ... (باقي الكود زي ما هو) ...
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Text(
                article.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
