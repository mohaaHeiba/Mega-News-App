import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mega_news_app/app.dart';
import 'package:mega_news_app/features/welcome/welcome_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // load apis from enviroment
  await dotenv.load(fileName: ".env");

  //init supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_APIKEY']!,
  );

  //load theme adn state
  await GetStorage.init();

  GetStorage().erase();

  Get.lazyPut(() => WelcomeController());

  runApp(const MyApp());
}
