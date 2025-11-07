import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mega_news_app/features/article_detail/pages/article_detail_page.dart';
import 'package:mega_news_app/features/briefing/controller/briefing_controller.dart';
import 'package:mega_news_app/core/utils/app_context_helper.dart';
import 'package:shimmer/shimmer.dart';

class AiBriefingPage extends StatelessWidget {
  const AiBriefingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ctrl = Get.put(AiBriefingController());
    final helper = AppContextHelper(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          helper.s.briefing,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Obx(
            () => ctrl.isLoading.value
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: ctrl.fetchBriefings,
                  ),
          ),
        ],
      ),
      // --- 🚀 1. حذف الـ Column وإرجاع الـ Obx هو الـ body ---
      body: Obx(() {
        // --- حالة التحميل (Shimmer) ---
        if (ctrl.isLoading.value && ctrl.summaries.isEmpty) {
          return _buildShimmer(context, theme, ctrl.getTopicsToBrief().length);
        }

        // --- حالة عرض النتايج ---
        // --- 🚀 2. الـ RefreshIndicator بقى هو الـ child المباشر للـ Obx ---
        return RefreshIndicator(
          onRefresh: ctrl.fetchBriefings,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
            ),
            itemCount: ctrl.summaries.length,
            itemBuilder: (context, index) {
              final item = ctrl.summaries[index];
              return _buildTopicTile(context, theme, item);
            },
          ),
        );
      }),
    );
  }

  /// (ميثود _buildTopicTile زي ما هي بالظبط)
  Widget _buildTopicTile(
    BuildContext context,
    ThemeData theme,
    TopicSummary item,
  ) {
    final helper = AppContextHelper(context);
    return Card(
      elevation: 2,
      shadowColor: theme.shadowColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Get.to(
            () => ArticleDetailPage(
              topic: item.topicLabel,
              summary: item.summary,
              article: null,
            ),
            transition: Transition.rightToLeftWithFade,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(item.icon, color: theme.primaryColor, size: 48),
              const SizedBox(height: 16),
              Text(
                item.topicLabel,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                helper.s.viewAiSummary,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// (ميثود _buildShimmer زي ما هي بالظبط)
  Widget _buildShimmer(BuildContext context, ThemeData theme, int count) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0,
        ),
        itemCount: count,
        itemBuilder: (context, index) {
          return Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(width: 120, height: 16, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(width: 80, height: 12, color: Colors.white),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
