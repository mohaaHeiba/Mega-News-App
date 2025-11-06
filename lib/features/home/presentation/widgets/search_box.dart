import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mega_news_app/features/home/presentation/controller/home_controller.dart';
import 'package:mega_news_app/features/home/presentation/widgets/voice_search.dart';
import 'package:mega_news_app/features/home/domain/entities/article.dart';

class SearchBox extends StatelessWidget {
  const SearchBox({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () async {
        final ctrl = Get.find<HomeController>();
        final result = await showSearch<Article?>(
          context: context,
          delegate: ArticleSearchDelegate(ctrl),
        );
        if (result != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(result.title)));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.search),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Search news, topics, or sources',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.mic),
          ],
        ),
      ),
    );
  }
}
