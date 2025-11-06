import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mega_news_app/app.dart';
import 'package:mega_news_app/features/welcome/welcome_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Get.lazyPut(() => WelcomeController());

  runApp(const MyApp());
}
