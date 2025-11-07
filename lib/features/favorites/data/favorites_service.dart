import 'package:mega_news_app/core/service/network_service.dart';
import 'package:mega_news_app/core/errors/supabase_exception.dart';
import 'package:mega_news_app/features/news/domain/entities/article.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesService {
  final supabase = Supabase.instance.client;

  /// Get all favorites for the current user from Supabase
  Future<List<Article>> getFavorites(String userId) async {
    if (!await NetworkService.isConnected) {
      throw const NetworkAppException('No internet connection.');
    }

    try {
      final response = await supabase
          .from('favorites')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response.map<Article>((item) {
        final articleData = item['article_data'] as Map<String, dynamic>;
        return Article(
          id: articleData['id'] as String,
          title: articleData['title'] as String,
          description: articleData['description'] as String?,
          imageUrl: articleData['imageUrl'] as String?,
          sourceName: articleData['sourceName'] as String,
          articleUrl: articleData['articleUrl'] as String,
          publishedAt: DateTime.parse(articleData['publishedAt'] as String),
        );
      }).toList();
    } on PostgrestException catch (e) {
      throw SupabaseAppException('Failed to fetch favorites: ${e.message}');
    } catch (e) {
      throw SupabaseAppException('Unexpected error: ${e.toString()}');
    }
  }

  /// Add a favorite article to Supabase
  Future<void> addFavorite(String userId, Article article) async {
    if (!await NetworkService.isConnected) {
      throw const NetworkAppException('No internet connection.');
    }

    try {
      await supabase.from('favorites').insert({
        'user_id': userId,
        'article_id': article.id,
        'article_data': {
          'id': article.id,
          'title': article.title,
          'description': article.description,
          'imageUrl': article.imageUrl,
          'sourceName': article.sourceName,
          'articleUrl': article.articleUrl,
          'publishedAt': article.publishedAt.toIso8601String(),
        },
      });
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        // Unique constraint violation - article already favorited
        return; // Silently ignore if already exists
      }
      throw SupabaseAppException('Failed to add favorite: ${e.message}');
    } catch (e) {
      throw SupabaseAppException('Unexpected error: ${e.toString()}');
    }
  }

  /// Remove a favorite article from Supabase
  Future<void> removeFavorite(String userId, String articleId) async {
    if (!await NetworkService.isConnected) {
      throw const NetworkAppException('No internet connection.');
    }

    try {
      await supabase
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('article_id', articleId);
    } on PostgrestException catch (e) {
      throw SupabaseAppException('Failed to remove favorite: ${e.message}');
    } catch (e) {
      throw SupabaseAppException('Unexpected error: ${e.toString()}');
    }
  }

  /// Clear all favorites for a user from Supabase
  Future<void> clearAllFavorites(String userId) async {
    if (!await NetworkService.isConnected) {
      throw const NetworkAppException('No internet connection.');
    }

    try {
      await supabase
          .from('favorites')
          .delete()
          .eq('user_id', userId);
    } on PostgrestException catch (e) {
      throw SupabaseAppException('Failed to clear favorites: ${e.message}');
    } catch (e) {
      throw SupabaseAppException('Unexpected error: ${e.toString()}');
    }
  }

  /// Sync local favorites to Supabase (for offline-to-online sync)
  Future<void> syncFavoritesToSupabase(
    String userId,
    List<Article> articles,
  ) async {
    if (!await NetworkService.isConnected) {
      throw const NetworkAppException('No internet connection.');
    }

    try {
      // Get existing favorites from Supabase
      final existingResponse = await supabase
          .from('favorites')
          .select('article_id')
          .eq('user_id', userId);

      final existingIds = existingResponse
          .map<String>((item) => item['article_id'] as String)
          .toSet();

      // Add only new favorites
      final newArticles = articles
          .where((article) => !existingIds.contains(article.id))
          .toList();

      if (newArticles.isEmpty) return;

      await supabase.from('favorites').insert(
        newArticles.map((article) => {
          'user_id': userId,
          'article_id': article.id,
          'article_data': {
            'id': article.id,
            'title': article.title,
            'description': article.description,
            'imageUrl': article.imageUrl,
            'sourceName': article.sourceName,
            'articleUrl': article.articleUrl,
            'publishedAt': article.publishedAt.toIso8601String(),
          },
        }).toList(),
      );
    } on PostgrestException catch (e) {
      throw SupabaseAppException('Failed to sync favorites: ${e.message}');
    } catch (e) {
      throw SupabaseAppException('Unexpected error: ${e.toString()}');
    }
  }
}

