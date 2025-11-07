// lib/features/search/presentation/pages/show_search_page.dart

import 'package:flutter/material.dart'
    hide SearchController; // <-- 1. رجعنا الـ import صح
import 'package:get/get.dart';
import 'package:mega_news_app/features/home/presentation/widgets/article_tile.dart';
// اتأكد إن الـ path ده صح (المكان الجديد بعد النقل)
import 'package:mega_news_app/features/search/presentation/controller/search_controller.dart';

class ShowSearchPage extends StatelessWidget {
  const ShowSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SearchController ctrl = Get.put(SearchController());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        // 2. --- 🚀 بداية تعديل الشكل ---
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        // 3. عملنا Container شكله حلو
        title: Container(
          height: 44,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(22), // شكل دائري
          ),
          child: Row(
            children: [
              // 4. أيقونة البحث
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Icon(Icons.search, color: theme.hintColor),
              ),
              // 5. الـ TextField من غير حدود
              Expanded(
                child: TextField(
                  controller: ctrl.textController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Search news, topics...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
              // 6. زرار المايك
              Obx(
                () => IconButton(
                  icon: Icon(
                    ctrl.isListening.value ? Icons.mic : Icons.mic_none,
                    color: ctrl.isListening.value
                        ? Colors.red
                        : theme.hintColor,
                  ),
                  onPressed: ctrl.isListening.value
                      ? ctrl.stopListening
                      : ctrl.startListening,
                ),
              ),
            ],
          ),
        ),
        // --- نهاية تعديل الشكل ---
      ),
      body: SafeArea(
        child: Obx(() {
          // ... (باقي الكود بتاعك زي ما هو) ...
          if (ctrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (ctrl.articles.isEmpty && ctrl.textController.text.isNotEmpty) {
            return const Center(child: Text('No results found.'));
          }
          if (ctrl.articles.isEmpty && ctrl.textController.text.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 60, color: Colors.grey),
                  Text('Search for news', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: ctrl.articles.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final article = ctrl.articles[index];
              return ArticleTile(article: article);
            },
          );
        }),
      ),
    );
  }
}
