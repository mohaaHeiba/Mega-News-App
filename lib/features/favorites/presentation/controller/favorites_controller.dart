import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mega_news_app/features/news/domain/entities/article.dart';
import 'package:mega_news_app/generated/l10n.dart';

class FavoritesController extends GetxController {
  final storage = GetStorage();
  final favorites = <Article>[].obs;
  static const String _favoritesKey = 'favorite_articles';

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  void loadFavorites() {
    final saved = storage.read<List>(_favoritesKey);
    if (saved != null) {
      favorites.value = saved
          .map((item) => Article(
                id: item['id'],
                title: item['title'],
                description: item['description'],
                imageUrl: item['imageUrl'],
                sourceName: item['sourceName'],
                articleUrl: item['articleUrl'],
                publishedAt: DateTime.parse(item['publishedAt']),
              ))
          .toList();
    }
  }

  void _saveFavorites() {
    final toSave = favorites.map((article) => {
          'id': article.id,
          'title': article.title,
          'description': article.description,
          'imageUrl': article.imageUrl,
          'sourceName': article.sourceName,
          'articleUrl': article.articleUrl,
          'publishedAt': article.publishedAt.toIso8601String(),
        }).toList();
    storage.write(_favoritesKey, toSave);
  }

  bool isFavorite(Article article) {
    return favorites.any((fav) => fav.id == article.id);
  }

  void toggleFavorite(Article article) {
    final s = S.current;
    if (isFavorite(article)) {
      favorites.removeWhere((fav) => fav.id == article.id);
      Get.snackbar(
        s.removedFromFavorites,
        s.articleRemovedFromFavorites,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } else {
      favorites.add(article);
      Get.snackbar(
        s.addedToFavorites,
        s.articleSavedToFavorites,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
    _saveFavorites();
  }

  void removeFavorite(Article article) {
    final s = S.current;
    favorites.removeWhere((fav) => fav.id == article.id);
    _saveFavorites();
    Get.snackbar(
      s.removed,
      s.articleRemovedFromFavoritesShort,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void clearAllFavorites() {
    final s = S.current;
    favorites.clear();
    storage.remove(_favoritesKey);
    Get.snackbar(
      s.cleared,
      s.allFavoritesCleared,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}

