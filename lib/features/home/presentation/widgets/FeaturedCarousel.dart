import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:mega_news_app/features/home/domain/entities/article.dart';
import 'package:mega_news_app/features/home/presentation/widgets/FeaturedArticle.dart';

class FeaturedCarousel extends StatelessWidget {
  final List<Article> articles;
  const FeaturedCarousel({super.key, required this.articles});

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) return const SizedBox.shrink();

    final bool enableAuto = articles.length > 1;

    return SizedBox(
      height: 200,
      child: CarouselSlider(
        options: CarouselOptions(
          height: 200,
          viewportFraction: 1.0, // عرض العنصر يملأ الشاشة
          autoPlay: enableAuto, // تشغيل آلي لو أكثر من عنصر
          enableInfiniteScroll: enableAuto, // تكرار لا نهائي
        ),
        items: articles.map((a) => FeaturedArticle(article: a)).toList(),
      ),
    );
  }
}
