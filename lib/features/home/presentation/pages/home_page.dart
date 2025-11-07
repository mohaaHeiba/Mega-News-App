import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mega_news_app/core/constants/app_const.dart';
import 'package:mega_news_app/core/utils/app_context_helper.dart';
import 'package:mega_news_app/features/home/presentation/controller/home_controller.dart';
import 'package:mega_news_app/features/home/presentation/widgets/article_tile.dart';
import 'package:mega_news_app/features/home/presentation/widgets/slider/carousel_slider_widget.dart';
import 'package:mega_news_app/features/home/presentation/widgets/search_box.dart';
import 'package:mega_news_app/features/home/presentation/widgets/build_shimmer_list.dart';
import 'package:mega_news_app/features/home/presentation/widgets/category_chip.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController ctrl = Get.put(HomeController());
    final theme = Theme.of(context);
    final helper = AppContextHelper(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', width: 50),
            Text(
              helper.s.megaNews,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),

      // ============================
      // MAIN CONTENT (Reactive UI)
      // ============================
      body: SafeArea(
        child: Obx(() {
          // =======================================================
          // LOADING STATE (Shimmer placeholders while fetching)
          // =======================================================
          if (ctrl.isLoading.value) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search and categories stay visible while loading
                  const SearchBox(),
                  AppConst.h12,

                  // Category chips
                  SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: ctrl.getCategories().length,
                      itemBuilder: (context, index) {
                        final cat = ctrl.getCategories()[index];
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
                  AppConst.h16,

                  // Shimmer skeletons
                  Text(helper.s.featured, style: theme.textTheme.titleMedium),
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
                  AppConst.h20,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(helper.s.latest, style: theme.textTheme.titleMedium),
                      TextButton(onPressed: null, child: Text(helper.s.seeAll)),
                    ],
                  ),
                  AppConst.h8,
                  buildShimmerList(),
                ],
              ),
            );
          }

          // =======================================================
          // EMPTY STATE (No articles found)
          // =======================================================
          if (ctrl.articles.isEmpty) {
            return Center(child: Text(helper.s.noNewsFound));
          }

          // =======================================================
          // DATA STATE (Display articles)
          // =======================================================
          final articles = ctrl.articles;
          return RefreshIndicator(
            onRefresh: () => ctrl.fetchNews(forceRefresh: true),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search box
                  const SearchBox(),
                  const SizedBox(height: 14),

                  // Category chips
                  SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: ctrl.getCategories().length,
                      itemBuilder: (context, index) {
                        final cat = ctrl.getCategories()[index];
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
                  AppConst.h16,

                  // Featured section (carousel)
                  Text(helper.s.featured, style: theme.textTheme.titleMedium),
                  AppConst.h8,
                  // Show first 5 articles in the carousel
                  CarouselSliderWidget(articles: articles.take(5).toList()),
                  AppConst.h20,

                  // Latest section
                  AppConst.h8,

                  // Show remaining articles (after first 5)
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: (articles.length > 5) ? articles.length - 5 : 0,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return ArticleTile(article: articles[index + 5]);
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
