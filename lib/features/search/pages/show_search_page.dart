import 'dart:math';
import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import 'package:mega_news_app/features/home/presentation/widgets/article_tile.dart';
import 'package:mega_news_app/features/search/controller/search_controller.dart';

class ShowSearchPage extends StatelessWidget {
  const ShowSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SearchController ctrl = Get.put(SearchController());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // --- 🚀 1. إضافة الـ FloatingActionButton ---
      floatingActionButton: Obx(() {
        // 2. بنظهره بس لو في نتايج، ومفيش تحميل شغال
        if (ctrl.articles.isNotEmpty &&
            !ctrl.isLoading.value &&
            !ctrl.isSummarizing.value) {
          return FloatingActionButton.extended(
            onPressed:
                ctrl.summarizeSearchResults, // <-- 3. الربط بالميثود الجديدة
            label: const Text('Summarize Results'),
            icon: const Icon(Icons.auto_awesome_rounded),
          );
        } else if (ctrl.isSummarizing.value) {
          // 4. (اختياري) إظهار Spinner لو الـ AI بيحمل
          return FloatingActionButton(
            onPressed: () {},
            backgroundColor: theme.disabledColor,
            child: const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        } else {
          return const SizedBox.shrink(); // 5. إخفاء الزرار
        }
      }),

      // --- نهاية الإضافة ---
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              elevation: 0,
              backgroundColor: theme.scaffoldBackgroundColor,
              floating: true,
              snap: true,
              expandedHeight: 0,
              toolbarHeight: 72,
              automaticallyImplyLeading: false,
              title: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : theme.cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Icon(
                        Icons.search_rounded,
                        color: theme.hintColor,
                        size: 22,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: ctrl.textController,
                        autofocus: true,
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search news, topics...',
                          hintStyle: TextStyle(
                            color: theme.hintColor,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    Obx(
                      () => ctrl.searchQuery.value.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear_rounded,
                                color: theme.hintColor,
                                size: 20,
                              ),
                              onPressed: () {
                                ctrl.textController.clear();
                              },
                            )
                          : const SizedBox.shrink(),
                    ),
                    Obx(
                      () => Container(
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: ctrl.isListening.value
                              ? Colors.red.withOpacity(0.1)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            ctrl.isListening.value
                                ? Icons.mic_rounded
                                : Icons.mic_none_rounded,
                            color: ctrl.isListening.value
                                ? Colors.red
                                : theme.hintColor,
                            size: 22,
                          ),
                          onPressed: ctrl.isListening.value
                              ? ctrl.stopListening
                              : ctrl.startListening,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- (باقي الكود زي ما هو بالظبط) ---
            // (Obx, SliverList, Shimmer, etc.)
            // ...
            Obx(() {
              // Loading state with shimmer effect
              if (ctrl.isLoading.value) {
                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildShimmerCard(theme, isDark),
                      childCount: 5,
                    ),
                  ),
                );
              }

              // No results state
              if (ctrl.articles.isEmpty &&
                  ctrl.textController.text.isNotEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No results found',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try different keywords',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Empty state
              if (ctrl.articles.isEmpty && ctrl.textController.text.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.search_rounded,
                            size: 60,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Discover News',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Search for topics you\'re interested in',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Results with count header
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverMainAxisGroup(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Text(
                              '${ctrl.articles.length} Results',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                            const Spacer(),
                            Obx(
                              () => Text(
                                'for "${ctrl.searchQuery.value}"',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        if (index.isOdd) {
                          return const SizedBox(height: 16);
                        }
                        final itemIndex = index ~/ 2;
                        final article = ctrl.articles[itemIndex];
                        return ArticleTile(article: article);
                      }, childCount: max(0, ctrl.articles.length * 2 - 1)),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerCard(ThemeData theme, bool isDark) {
    final shimmerColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: shimmerColor,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 16,
            width: double.infinity,
            decoration: BoxDecoration(
              color: shimmerColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 16,
            width: 200,
            decoration: BoxDecoration(
              color: shimmerColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
