import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mega_news_app/features/home/presentation/widgets/show_search_page.dart';
// ستحتاج لإنشاء هذه الصفحة لاحقاً

class SearchBox extends StatelessWidget {
  const SearchBox({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        // للانتقال لصفحة البحث
        Get.to(() => const ShowSearchPage());
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor, // لون الكارت
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
                  color: theme.hintColor, // لون النص التلميحي
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
