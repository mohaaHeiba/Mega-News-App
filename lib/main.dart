import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mega_news_app/app.dart';
import 'package:mega_news_app/core/service/background_service.dart';
import 'package:mega_news_app/core/service/notification_service.dart';
import 'package:mega_news_app/features/favorites/presentation/controller/favorites_controller.dart';
import 'package:mega_news_app/features/welcome/welcome_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // load apis from enviroment
  await dotenv.load(fileName: ".env");

  //init supabase
  Gemini.init(apiKey: dotenv.env['GEMINI_API']!);

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_APIKEY']!,
  );

  //load theme adn state
  await GetStorage.init();

  // Store API keys in GetStorage for background tasks
  final storage = GetStorage();
  storage.write('GNEWS_API', dotenv.env['GNEWS_API']);
  storage.write('NEWS_API', dotenv.env['NEWS_API']);
  storage.write('NEW_DATA', dotenv.env['NEW_DATA']);

  // Initialize notification service FIRST (required for background service)
  try {
    final notificationService = NotificationService();
    await notificationService.initialize();
    print('Notification service initialized successfully');
  } catch (e) {
    print('Error initializing notification service: $e');
  }

  // Initialize and start background service (non-blocking)
  // Wait a bit longer to ensure notification channels are created
  try {
    await BackgroundService.initialize();
    print('Background service initialized successfully');
    // Delay starting the service to ensure app is fully loaded and channels are ready
    Future.delayed(const Duration(seconds: 3), () async {
      try {
        await BackgroundService.start();
        print('Background service started successfully');
      } catch (e) {
        print('Error starting background service: $e');
      }
    });
  } catch (e) {
    print('Error initializing background service: $e');
  }

  // GetStorage().erase();

  Get.lazyPut(() => WelcomeController());
  Get.put(FavoritesController(), permanent: true);

  runApp(const MyApp());
}
