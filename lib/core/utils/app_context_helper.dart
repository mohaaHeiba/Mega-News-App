import 'package:flutter/material.dart';
import 'package:mega_news_app/generated/l10n.dart';

class AppContextHelper {
  final BuildContext context;
  AppContextHelper(this.context);

  S get s => S.of(context);

  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;
}
