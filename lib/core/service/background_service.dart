import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mega_news_app/core/network/api_cleint.dart';
import 'package:mega_news_app/core/service/notification_service.dart';
import 'package:mega_news_app/features/news/data/datasources/gnews_remote_datasource.dart';
import 'package:mega_news_app/features/news/data/datasources/newsapi_remote_datasource.dart';
import 'package:mega_news_app/features/news/data/datasources/newsdata_remote_datasource.dart';
import 'package:mega_news_app/features/news/data/mappers/article_mapper.dart';
import 'package:mega_news_app/features/news/domain/repositories/news_repository_impl.dart';

/// Background task function - fetches news and shows notifications
@pragma('vm:entry-point')
Future<void> fetchNewsInBackground(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: "Mega News",
      content: "Checking for new articles...",
    );
  }

  try {
    // Initialize GetStorage
    await GetStorage.init();
    
    // Get API keys from storage (stored during app initialization)
    final storage = GetStorage();
    final gnewsApiKey = storage.read<String>('GNEWS_API') ?? '';
    final newsApiKey = storage.read<String>('NEWS_API') ?? '';
    final newsDataApiKey = storage.read<String>('NEW_DATA') ?? '';

    // Try to load environment variables, but use GetStorage as fallback
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      // If dotenv fails, that's okay - we'll use stored values
      print('Could not load .env in background, using stored values');
    }
    
    // Always override with stored values to ensure they're available
    // This ensures API keys work even if .env file isn't accessible in background
    if (gnewsApiKey.isNotEmpty) {
      dotenv.env['GNEWS_API'] = gnewsApiKey;
    }
    if (newsApiKey.isNotEmpty) {
      dotenv.env['NEWS_API'] = newsApiKey;
    }
    if (newsDataApiKey.isNotEmpty) {
      dotenv.env['NEW_DATA'] = newsDataApiKey;
    }

    // Setup API client
    final dio = Dio();
    final apiClient = ApiClient(dio);

    // Initialize data sources (they will use dotenv.env which we just set)
    final gnews = GNewsRemoteDataSourceImpl(apiClient: apiClient);
    final newsapi = NewsApiRemoteDataSourceImpl(apiClient: apiClient);
    final newsdata = NewsDataRemoteDataSourceImpl(apiClient: apiClient);
    final mapper = ArticleMapper();

    // Build repository
    final newsRepository = NewsRepositoryImpl(
      gNewsDataSource: gnews,
      newsApiDataSource: newsapi,
      newsDataDataSource: newsdata,
      mapper: mapper,
    );

    // Get the last fetched article IDs from storage
    final lastArticleIds = List<String>.from(
      storage.read('lastArticleIds') ?? [],
    );

    // Update notification
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: "Mega News",
        content: "Fetching latest news...",
      );
    }

    // Fetch latest news (general category)
    final articles = await newsRepository.getTopHeadlines(
      category: 'general',
    );

    if (articles.isEmpty) {
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: "Mega News",
          content: "No new articles found",
        );
      }
      return;
    }

    // Filter out articles we've already seen
    final newArticles = articles
        .where((article) => !lastArticleIds.contains(article.id))
        .toList();

    if (newArticles.isNotEmpty) {
      // Update stored article IDs (keep last 100)
      final currentIds = articles.take(100).map((a) => a.id).toList();
      await storage.write('lastArticleIds', currentIds);

      // Initialize notification service for background use (no permission requests)
      final notificationService = NotificationService();
      await notificationService.initializeForBackground();

      // Prepare notification data
      final notificationData = newArticles.map((article) {
        return {
          'title': article.title,
          'description': article.description ?? 'New article available',
          'url': article.articleUrl,
        };
      }).toList();

      // Show notifications
      await notificationService.showMultipleNewsNotifications(
        notificationData,
      );

      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: "Mega News",
          content: "Found ${newArticles.length} new article(s)",
        );
      }
    } else {
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: "Mega News",
          content: "No new articles",
        );
      }
    }
  } catch (e) {
    // Log error
    print('Background task error: $e');
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: "Mega News",
        content: "Error: ${e.toString()}",
      );
    }
  }
}

class BackgroundService {
  /// Initialize and configure the background service
  static Future<void> initialize() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false, // Disable auto-start to prevent crashes on app launch
        isForegroundMode: true,
        notificationChannelId: 'news_background',
        initialNotificationTitle: 'Mega News',
        initialNotificationContent: 'Background service is running',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false, // Disable auto-start to prevent crashes on app launch
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  /// Start the background service
  static Future<void> start() async {
    final service = FlutterBackgroundService();
    bool isRunning = await service.isRunning();
    
    if (!isRunning) {
      await service.startService();
    }
  }

  /// Stop the background service
  static Future<void> stop() async {
    final service = FlutterBackgroundService();
    bool isRunning = await service.isRunning();
    
    if (isRunning) {
      service.invoke("stopService");
    }
  }
}

/// Android background service entry point
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Run the fetch function immediately
  await fetchNewsInBackground(service);

  // Set up periodic timer to run every 2 hours
  Timer.periodic(const Duration(hours: 2), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        await fetchNewsInBackground(service);
      }
    } else {
      await fetchNewsInBackground(service);
    }
  });
}

/// iOS background handler
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  return true;
}
