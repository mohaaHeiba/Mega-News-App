import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mega_news_app/features/home/presentation/controller/home_controller.dart';
import 'package:mega_news_app/features/home/presentation/widgets/ArticleTile.dart';
import 'package:mega_news_app/features/home/presentation/widgets/FeaturedCarousel.dart';
import 'package:mega_news_app/features/home/presentation/widgets/Search_box.dart';
import 'package:mega_news_app/features/home/presentation/widgets/category_chip.dart';
import 'package:shimmer/shimmer.dart';
// تأكد من وجود الكنترولر والـ entity الذي أرسلته في الرد السابق

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // استخدم Get.put إذا كانت هذه أول مرة تستدعي فيها الكنترولر
    // استخدم Get.find إذا تم عمل put له في مكان آخر (مثل ملف الـ bindings)
    final HomeController ctrl = Get.put(HomeController());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        // استخدمت Text بدلاً من الشعار كحل مؤقت
        title: const Text(
          'Mega News',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.bookmark_border), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          // --- حالة التحميل (Loading State) ---
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
                  _buildShimmerList(), // Shimmer list
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

  // ويدجت مساعدة لبناء الـ Shimmer List
  Widget _buildShimmerList() {
    return ListView.separated(
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
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 14, color: Colors.white),
                        const SizedBox(height: 8),
                        Container(height: 12, color: Colors.white),
                        const SizedBox(height: 8),
                        Container(height: 12, width: 80, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
