import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mega_news_app/features/home/presentation/controller/home_controller.dart';
import 'package:shimmer/shimmer.dart';
import 'package:mega_news_app/features/home/presentation/widgets/search_box.dart';
import 'package:mega_news_app/features/home/presentation/widgets/category_chip.dart';
import 'package:mega_news_app/features/home/presentation/widgets/article_tile.dart';
import 'package:mega_news_app/features/home/presentation/widgets/featured_carousel.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController ctrl = Get.put(HomeController());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/logo.png', width: 60),
        actions: [
          IconButton(icon: const Icon(Icons.bookmark_border), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (ctrl.isLoading.value) {
            // Shimmer skeleton while loading
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Keep actual search box and categories interactive during loading
                  const SearchBox(),

                  const SizedBox(height: 14),

                  // Categories (still usable while content loads)
                  SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: ctrl.categories.length,
                      itemBuilder: (context, index) {
                        final cat = ctrl.categories[index];
                        final isSelected =
                            ctrl.selectedCategory.value == cat['value'];
                        return CategoryChip(
                          label: cat['label']!,
                          selected: isSelected,
                          onTap: () => ctrl.changeCategory(cat['value']!),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Featured skeleton (carousel)
                  Text('Featured', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Latest skeleton list
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Latest', style: theme.textTheme.titleMedium),
                      TextButton(onPressed: null, child: const Text('See all')),
                    ],
                  ),
                  const SizedBox(height: 8),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Material(
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 110,
                                  height: 72,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 14,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        height: 12,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        height: 12,
                                        width: 80,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }

          if (ctrl.articles.isEmpty) {
            return const Center(child: Text('No news found'));
          }

          final articles = ctrl.articles;

          return RefreshIndicator(
            onRefresh: ctrl.fetchNews,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔍 Search box
                  SearchBox(),

                  const SizedBox(height: 14),

                  // 🏷 Categories
                  SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: ctrl.categories.length,
                      itemBuilder: (context, index) {
                        final cat = ctrl.categories[index];
                        final isSelected =
                            ctrl.selectedCategory.value == cat['value'];
                        return CategoryChip(
                          label: cat['label']!,
                          selected: isSelected,
                          onTap: () => ctrl.changeCategory(cat['value']!),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 🌟 Featured (carousel when multiple)
                  Text('Featured', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  FeaturedCarousel(articles: articles.take(5).toList()),

                  const SizedBox(height: 20),

                  // 🕓 Latest
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Latest', style: theme.textTheme.titleMedium),
                      TextButton(
                        onPressed: () {},
                        child: const Text('See all'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: articles.length - 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return ArticleTile(article: articles[index + 1]);
                    },
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
