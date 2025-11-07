import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mega_news_app/features/auth/data/auth_local.dart';
import 'package:mega_news_app/features/favorites/data/favorites_service.dart';
import 'package:mega_news_app/features/news/domain/entities/article.dart';
import 'package:mega_news_app/generated/l10n.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesController extends GetxController {
  final storage = GetStorage();
  final favoritesService = FavoritesService();
  final authLocal = AuthLocalService();
  final favorites = <Article>[].obs;
  final isLoading = false.obs;
  final isSyncing = false.obs;

  // Cache keys
  String get _favoritesKey {
    final user = authLocal.getAuthData();
    return user != null ? 'favorite_articles_${user.id}' : 'favorite_articles_guest';
  }

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  /// Get current user ID if logged in
  String? get _currentUserId {
    final user = authLocal.getAuthData();
    return user?.id;
  }

  /// Check if user is logged in
  bool get _isLoggedIn {
    final supabase = Supabase.instance.client;
    return supabase.auth.currentUser != null && _currentUserId != null;
  }

  /// Load favorites from Supabase (if logged in) or from cache
  Future<void> loadFavorites() async {
    isLoading.value = true;
    try {
      if (_isLoggedIn) {
        // Try to load from Supabase first
        try {
          final userId = _currentUserId!;
          final supabaseFavorites = await favoritesService.getFavorites(userId);
          favorites.value = supabaseFavorites;
          // Cache the favorites locally
          _saveFavoritesToCache();
        } catch (e) {
          // If Supabase fails, try loading from cache
          _loadFavoritesFromCache();
        }
      } else {
        // Not logged in, load from cache only
        _loadFavoritesFromCache();
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Load favorites from local cache
  void _loadFavoritesFromCache() {
    final saved = storage.read<List>(_favoritesKey);
    if (saved != null) {
      favorites.value = saved
          .map((item) => Article(
                id: item['id'] as String,
                title: item['title'] as String,
                description: item['description'] as String?,
                imageUrl: item['imageUrl'] as String?,
                sourceName: item['sourceName'] as String,
                articleUrl: item['articleUrl'] as String,
                publishedAt: DateTime.parse(item['publishedAt'] as String),
              ))
          .toList();
    } else {
      favorites.value = [];
    }
  }

  /// Save favorites to local cache
  void _saveFavoritesToCache() {
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

  /// Sync local cache to Supabase (called when user logs in)
  Future<void> syncToSupabase() async {
    if (!_isLoggedIn || favorites.isEmpty) return;

    isSyncing.value = true;
    try {
      final userId = _currentUserId!;
      await favoritesService.syncFavoritesToSupabase(userId, favorites);
    } catch (e) {
      // Silently fail - favorites are still cached locally
      print('Failed to sync favorites to Supabase: $e');
    } finally {
      isSyncing.value = false;
    }
  }

  bool isFavorite(Article article) {
    return favorites.any((fav) => fav.id == article.id);
  }

  Future<void> toggleFavorite(Article article) async {
    final s = S.current;
    if (isFavorite(article)) {
      await removeFavorite(article);
      Get.snackbar(
        s.removedFromFavorites,
        s.articleRemovedFromFavorites,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } else {
      await addFavorite(article);
      Get.snackbar(
        s.addedToFavorites,
        s.articleSavedToFavorites,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> addFavorite(Article article) async {
    // Add to local list immediately
    favorites.add(article);
    _saveFavoritesToCache();

    // Save to Supabase if logged in
    if (_isLoggedIn) {
      try {
        final userId = _currentUserId!;
        await favoritesService.addFavorite(userId, article);
      } catch (e) {
        // If Supabase fails, favorites are still cached locally
        print('Failed to save favorite to Supabase: $e');
      }
    }
  }

  Future<void> removeFavorite(Article article) async {
    final s = S.current;
    // Remove from local list immediately
    favorites.removeWhere((fav) => fav.id == article.id);
    _saveFavoritesToCache();

    // Remove from Supabase if logged in
    if (_isLoggedIn) {
      try {
        final userId = _currentUserId!;
        await favoritesService.removeFavorite(userId, article.id);
      } catch (e) {
        // If Supabase fails, favorites are still updated locally
        print('Failed to remove favorite from Supabase: $e');
      }
    }

    Get.snackbar(
      s.removed,
      s.articleRemovedFromFavoritesShort,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> clearAllFavorites() async {
    final s = S.current;
    favorites.clear();
    storage.remove(_favoritesKey);

    // Clear from Supabase if logged in
    if (_isLoggedIn) {
      try {
        final userId = _currentUserId!;
        await favoritesService.clearAllFavorites(userId);
      } catch (e) {
        // If Supabase fails, favorites are still cleared locally
        print('Failed to clear favorites from Supabase: $e');
      }
    }

    Get.snackbar(
      s.cleared,
      s.allFavoritesCleared,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  /// Called when user logs in - syncs cached favorites to Supabase
  Future<void> onUserLogin() async {
    // Load cached favorites first
    _loadFavoritesFromCache();
    // Then sync to Supabase
    await syncToSupabase();
    // Finally reload from Supabase to get the latest
    await loadFavorites();
  }

  /// Called when user logs out - clears user-specific data
  void onUserLogout() {
    // Clear current favorites
    favorites.clear();
    // Load guest favorites if any
    _loadFavoritesFromCache();
  }
}

