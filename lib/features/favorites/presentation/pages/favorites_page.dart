import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mega_news_app/core/constants/app_const.dart';
import 'package:mega_news_app/core/utils/app_context_helper.dart';
import 'package:mega_news_app/features/article_detail/pages/article_detail_page.dart';
import 'package:mega_news_app/features/favorites/presentation/controller/favorites_controller.dart';
import 'package:timeago/timeago.dart' as timeago;

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FavoritesController());
    final theme = Theme.of(context);
    final helper = AppContextHelper(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          helper.s.savedArticles,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(
            () => controller.favorites.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _showClearDialog(context, controller, helper),
                    tooltip: helper.s.clearAll,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Obx(
        () {
          if (controller.favorites.isEmpty) {
            return _buildEmptyState(theme, helper);
          }

          return RefreshIndicator(
            onRefresh: () async {
              controller.loadFavorites();
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: controller.favorites.length,
              separatorBuilder: (context, index) => AppConst.h12,
              itemBuilder: (context, index) {
                final article = controller.favorites[index];
                return _buildFavoriteArticleTile(
                  context,
                  article,
                  controller,
                  theme,
                  helper,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppContextHelper helper) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          AppConst.h24,
          Text(
            helper.s.noSavedArticles,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          AppConst.h8,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              helper.s.articlesYouSaveWillAppearHere,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteArticleTile(
    BuildContext context,
    article,
    FavoritesController controller,
    ThemeData theme,
    AppContextHelper helper,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Get.to(() => ArticleDetailPage(article: article));
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Article Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Hero(
                  tag: article.id,
                  child: Image.network(
                    article.imageUrl ?? '',
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                    errorBuilder: (context, _, __) => Container(
                      width: 110,
                      height: 110,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              AppConst.w12,
              // Article Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppConst.h8,
                    if (article.description != null) ...[
                      Text(
                        article.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      AppConst.h8,
                    ],
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        AppConst.w4,
                        Text(
                          timeago.format(article.publishedAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                        AppConst.w8,
                        Icon(
                          Icons.source,
                          size: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        AppConst.w4,
                        Expanded(
                          child: Text(
                            article.sourceName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Favorite Button
              IconButton(
                icon: Icon(
                  Icons.favorite,
                  color: Colors.red,
                ),
                onPressed: () => controller.removeFavorite(article),
                tooltip: helper.s.removeFromFavorites,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearDialog(
    BuildContext context,
    FavoritesController controller,
    AppContextHelper helper,
  ) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(helper.s.clearAllFavorites),
        content: Text(helper.s.clearAllFavoritesMessage),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(helper.s.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              controller.clearAllFavorites();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(helper.s.clearAll),
          ),
        ],
      ),
    );
  }
}

