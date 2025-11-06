import 'package:flutter/material.dart';
import 'package:mega_news_app/core/theme/app_colors.dart';
import 'package:mega_news_app/core/theme/app_gradients.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final PageController _imageController = PageController();
  final PageController _textController = PageController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> pages = [
    {
      "title": "News from Everywhere",
      "subtitle": "Follow news from multiple reliable sources in one app",
      "image": "assets/images/news_aggregation.png",
    },
    {
      "title": "Smart Search & Instant Summaries",
      "subtitle":
          "Search any topic and get a comprehensive summary of related news",
      "image": "assets/images/search_summary.png",
    },
    {
      "title": "Save What Matters",
      "subtitle": "Add important news to favorites and read them anytime",
      "image": "assets/images/favorites.png",
    },
    {
      "title": "Real-time Notifications",
      "subtitle": "Be the first to know breaking news from all sources",
      "image": "assets/images/notifications.png",
    },
  ];

  @override
  void dispose() {
    _imageController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    _textController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.newspaper_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'MegaNews',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textPrimary
                    : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
        actions: [
          if (_currentIndex < pages.length - 1)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: TextButton(
                onPressed: () {
                  _imageController.animateToPage(
                    pages.length - 1,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                  _textController.animateToPage(
                    pages.length - 1,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                },
                child: Text(
                  'Skip',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppGradients.dark.background
              : AppGradients.light.background,
        ),
        child: Column(
          children: [
            // --- (تعديل 1: تم زيادة المسافة لتنزيل الصورة) ---
            const SizedBox(height: 30), // كانت 16
            // ------------------------------------------

            // PageView للصور فقط
            SizedBox(
              height: size.height * 0.4,
              child: PageView.builder(
                controller: _imageController,
                onPageChanged: _onPageChanged,
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        pages[index]["image"]!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // PageView للنصوص Scrollable
            Expanded(
              child: PageView.builder(
                controller: _textController,
                physics:
                    const NeverScrollableScrollPhysics(), // منع السحب للنصوص
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Text(
                            page["title"]!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.textPrimary
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            page["subtitle"]!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark
                                  ? AppColors.textSecondary
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Page Indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentIndex == index ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: _currentIndex == index
                          ? LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withOpacity(0.7),
                              ],
                            )
                          : null,
                      color: _currentIndex != index
                          ? AppColors.primary.withOpacity(0.3)
                          : null,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: _currentIndex == index
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ),
            ),

            // Next / Get Started Button فقط
            // --- (تعديل 2: تم تقليل المسافة العلوية لرفع الزر) ---
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                10,
                20,
                20,
              ), // كانت (symmetric(horizontal: 20, vertical: 20
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentIndex < pages.length - 1) {
                      _imageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                      _textController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      // Navigate to home
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 6,
                    shadowColor: AppColors.primary.withOpacity(0.4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentIndex == pages.length - 1
                            ? 'Get Started'
                            : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        _currentIndex == pages.length - 1
                            ? Icons.rocket_launch_rounded
                            : Icons.arrow_back,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            // ------------------------------------------
          ],
        ),
      ),
    );
  }
}
