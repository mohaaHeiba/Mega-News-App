import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mega_news_app/features/news/domain/entities/article.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleDetailController extends GetxController {
  // --- 🚀 1. تعديل: خليناه يقبل null ---
  final Article? article;

  ArticleDetailController(this.article);

  // 🎨 ألوان ديناميكية
  var vibrantColor = Rxn<Color>();
  var vibrantTextColor = Rxn<Color>();

  @override
  void onInit() {
    super.onInit();
    // 🚀 2. هنتأكد إن المقال موجود قبل ما نجيب الألوان
    if (article != null) {
      _generatePalette();
    }
  }

  /// 🧩 استخراج اللون الحيوي من الصورة
  Future<void> _generatePalette() async {
    // 🚀 3. هنتأكد تاني (احتياطي)
    if (article == null ||
        article!.imageUrl == null ||
        article!.imageUrl!.isEmpty)
      return;

    try {
      final provider = NetworkImage(article!.imageUrl!);
      final palette = await PaletteGenerator.fromImageProvider(
        provider,
        size: const Size(100, 100),
      );

      if (palette.vibrantColor != null) {
        vibrantColor.value = palette.vibrantColor!.color;
        vibrantTextColor.value = palette.vibrantColor!.titleTextColor;
      }
    } catch (e) {
      debugPrint("⚠️ Failed to generate palette: $e");
    }
  }

  /// 🌐 فتح الرابط في المتصفح
  Future<void> openArticleLink() async {
    // 🚀 4. لو إحنا في وضع الملخص، الزرار ده مش هيعمل حاجة
    if (article == null) return;

    final uri = Uri.parse(article!.articleUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('Error', 'Could not open the link.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not open the link: $e');
    }
  }
}
