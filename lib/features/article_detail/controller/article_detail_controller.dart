import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mega_news_app/features/news/domain/entities/article.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleDetailController extends GetxController {
  final Article? article;

  ArticleDetailController(this.article);

  var vibrantColor = Rxn<Color>();
  var vibrantTextColor = Rxn<Color>();

  @override
  void onInit() {
    super.onInit();
    if (article != null) {
      _generatePalette();
    }
  }

  Future<void> _generatePalette() async {
    if (article == null ||
        article!.imageUrl == null ||
        article!.imageUrl!.isEmpty) {
      return;
    }

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
      debugPrint("Failed to generate palette: $e");
    }
  }

  Future<void> openArticleLink() async {
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
