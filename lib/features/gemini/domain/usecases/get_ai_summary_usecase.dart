/// lib/features/gemini/domain/usecases/get_ai_summary_usecase.dart
///
/// ده الـ Use Case (حالة الاستخدام) المحددة.
/// هو ده المكان اللي بنحط فيه الـ "System Prompt" وبنجهز الـ query.
import 'package:mega_news_app/features/gemini/domain/repositories/i_gemini_repository.dart';
import 'package:mega_news_app/features/news/domain/entities/article.dart'; // <-- 1. استدعاء Article

class GetAiSummaryUseCase {
  final IGeminiRepository _repository;

  GetAiSummaryUseCase(this._repository);

  /// --- 🚀 2. تعديل الميثود call ---
  /// (بقت بتاخد List<Article> وموضوع البحث)
  Future<String> call({
    required String topic,
    required List<Article> articles,
  }) async {
    // 3. بنجهز الـ Prompt هنا (في الـ Domain Layer)
    // --- 🚀 تعديل الـ Prompt ---
    const systemPrompt =
        'أنت خبير في تلخيص الأخبار. مهمتك هي قراءة قائمة من عناوين الأخبار ووصفها، ثم تقديم ملخص من فقرة واحدة (باللغة العربية) لأهم النقاط والأحداث. **ويجب أن تذكر أهم 3-4 مصادر (أسماء المواقع) التي وردت فيها هذه الأخبار في نهاية الملخص.**';

    // 4. بنحول الـ List لـ String واحد
    // --- 🚀 تعديل: ضفنا المصدر لكل مقال ---
    final articlesContent = articles
        .map(
          (a) =>
              'المصدر: ${a.sourceName}\nالعنوان: ${a.title}\nالوصف: ${a.description ?? ''}',
        )
        .join('\n\n');

    final userQuery =
        'الموضوع الرئيسي للبحث هو: "$topic".\n\nوهذه هي المقالات التي تم العثور عليها:\n$articlesContent\n\n---'
        '\n\nالرجاء تقديم ملخص (باللغة العربية) لهذه النتائج يتضمن أهم المصادر.';

    final fullPrompt = '$systemPrompt\n\n$userQuery';

    // 5. بنكلم الـ Repository
    return await _repository.generateText(fullPrompt);
  }
}
