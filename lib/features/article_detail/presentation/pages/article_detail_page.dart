import 'package:flutter/material.dart';
import 'package:get/get.dart'; // <-- 1. إضافة Get للـ Snackbar
import 'package:mega_news_app/features/news/domain/entities/article.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart'; // <-- 2. إضافة URL Launcher
// --- 🚀 1. إضافة Palette Generator ---
import 'package:palette_generator/palette_generator.dart';

// --- 🚀 2. تحويل لـ StatefulWidget ---
class ArticleDetailPage extends StatefulWidget {
  final Article article;
  const ArticleDetailPage({super.key, required this.article});

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  // --- 🚀 3. تعريف متغيرات الألوان ---
  Color? _vibrantColor;
  Color? _vibrantTextColor;

  @override
  void initState() {
    super.initState();
    // 4. نبدأ نجيب اللون أول ما الصفحة تفتح
    _generatePalette();
  }

  /// 5. ميثود جلب اللون من الصورة
  Future<void> _generatePalette() async {
    // لو مفيش صورة، مش هنعمل حاجة
    if (widget.article.imageUrl == null || widget.article.imageUrl!.isEmpty) {
      return;
    }

    try {
      final provider = NetworkImage(widget.article.imageUrl!);
      // بنجيب الألوان من الصورة
      final palette = await PaletteGenerator.fromImageProvider(
        provider,
        size: const Size(100, 100), // حجم أصغر لتحليل أسرع
      );

      // بنختار اللون "الحيوي" (Vibrant)
      if (palette.vibrantColor != null) {
        if (mounted) {
          // 6. بنخزن الألوان في الـ State عشان الـ UI يتحدث
          setState(() {
            _vibrantColor = palette.vibrantColor!.color;
            _vibrantTextColor = palette.vibrantColor!.titleTextColor;
          });
        }
      }
    } catch (e) {
      // لو حصل مشكلة في جلب الصورة (زي 404)
      debugPrint("Failed to generate palette: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 7. --- 🚀 استخدام الألوان الديناميكية ---
    // بنستخدم اللون اللي جبناه، ولو لسه مجاش، بنستخدم اللون الأساسي
    final Color dynamicColor = _vibrantColor ?? theme.colorScheme.primary;
    final Color dynamicTextColor = _vibrantTextColor ?? Colors.white;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // 🔹 AppBar أنيق بصورة وتدرج
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            stretch: true,
            elevation: 0,
            // --- 🚀 1. التعديل هنا: تثبيت لون الخلفية ---
            // هنخلي الخلفية دايماً بلون الصفحة عشان نلغي "النطة"
            backgroundColor: theme.scaffoldBackgroundColor,
            title: Text(
              widget.article.sourceName,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                shadows: [
                  const Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 4,
                    color: Colors.black38,
                  ),
                ],
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: widget.article.id,
                    child: Image.network(
                      widget.article.imageUrl ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.broken_image,
                          size: 60,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  // 🔹 تدرج ناعم وجذاب
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black54,
                          Colors.transparent,
                          Colors.black45,
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🔹 محتوى المقال
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    dynamicColor.withOpacity(0.1),
                    theme.colorScheme.surface,
                  ],
                  stops: const [0.0, 0.4],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔸 العنوان
                    Text(
                      widget.article.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 🔸 الوقت والمصدر
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${timeago.format(widget.article.publishedAt)}  •  ${widget.article.sourceName}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 🔸 المحتوى
                    Text(
                      widget.article.description ??
                          'No content available for this article.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        height: 1.6,
                        color: theme.colorScheme.onSurface.withOpacity(0.9),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // 🔸 زر فتح الرابط
                    Center(
                      child: AnimatedContainer(
                        duration: const Duration(
                          milliseconds: 300,
                        ), // زمن الأنيميشن
                        width: double.infinity,
                        // --- 🚀 2. التعديل هنا: إضافة اللون للـ Decoration ---
                        decoration: BoxDecoration(
                          color: dynamicColor, // اللون هيتحرك بأنيميشن
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: dynamicColor.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        // --- نهاية التعديل ---
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Read Full Story'),
                          style: ElevatedButton.styleFrom(
                            // --- 🚀 3. التعديل هنا: إلغاء اللون والـ Elevation ---
                            backgroundColor: Colors.transparent,
                            foregroundColor: dynamicTextColor,
                            elevation: 0, // بنلغي الـ shadow بتاع الزرار
                            // --- نهاية التعديل ---
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(fontSize: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () async {
                            final uri = Uri.parse(widget.article.articleUrl);
                            try {
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              } else {
                                Get.snackbar(
                                  'Error',
                                  'Could not open the link.',
                                );
                              }
                            } catch (e) {
                              Get.snackbar(
                                'Error',
                                'Could not open the link: $e',
                              );
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
