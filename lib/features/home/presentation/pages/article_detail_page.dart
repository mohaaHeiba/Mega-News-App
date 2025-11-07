// lib/features/article_detail/presentation/pages/article_detail_page.dart
import 'package:flutter/material.dart';
import 'package:mega_news_app/features/news/domain/entities/article.dart';
// 1. استدعاء Timeago
import 'package:timeago/timeago.dart' as timeago;

class ArticleDetailPage extends StatelessWidget {
  final Article article;
  const ArticleDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        // 2. تعديل الـ Source
        title: Text(article.sourceName),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              // 3. تعديل الـ Tag
              tag: article.id,
              child: Image.network(
                // 4. تعديل الـ Image
                article.imageUrl ?? '', // Handle null
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 250,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        // 5. تعديل الوقت والـ Source
                        '${timeago.format(article.publishedAt)}  •  ${article.sourceName}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    // 6. تعديل الـ Summary وإلغاء الـ Lorem Ipsum
                    article.description ??
                        'No content available for this article.',
                    style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
