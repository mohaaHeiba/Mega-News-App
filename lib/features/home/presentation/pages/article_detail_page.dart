import 'package:flutter/material.dart';
import 'package:mega_news_app/features/home/domain/entities/article.dart';

class ArticleDetailPage extends StatelessWidget {
  final Article article;
  const ArticleDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          article.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Hero(
              tag: article.title,
              child: Image.network(
                article.image,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (context, _, __) => Container(
                  height: 220,
                  color: Colors.grey.shade200,
                  child: const Icon(
                    Icons.broken_image,
                    size: 56,
                    color: Colors.grey,
                  ),
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
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        article.time,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    article.summary,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  // Placeholder for full content / original URL
                  ElevatedButton.icon(
                    onPressed: () {
                      // Could open the original article URL in a webview or browser
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Open original article')),
                      );
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open original'),
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
