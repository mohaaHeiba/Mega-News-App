import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', width: 50),
            const Text(
              'Mega News',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (ctrl.isLoading.value) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search box and categories are interactive even during load
                  const SearchBox(),
                  const SizedBox(height: 14),
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

                  // --- Shimmer Skeletons ---
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Latest', style: theme.textTheme.titleMedium),
                      TextButton(onPressed: null, child: const Text('See all')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  buildShimmerList(), // Shimmer list
                ],
              ),
            );
          }

          // --- حالة عدم وجود بيانات (Empty State) ---
          if (ctrl.articles.isEmpty) {
            return const Center(child: Text('No news found'));
          }

          // --- حالة عرض البيانات (Data State) ---
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
                  const SearchBox(),
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

                  // 🌟 Featured (carousel)
                  Text('Featured', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  // نعرض أول 5 مقالات فقط في الـ carousel
                  CarouselSliderWidget(articles: articles.take(5).toList()),
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

                  // نعرض باقي المقالات هنا (بعد أول 5)
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    // نتجاهل أول 5 مقالات لأنها في الـ featured
                    itemCount: (articles.length > 5) ? articles.length - 5 : 0,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      // نبدأ من المقال رقم 5
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
