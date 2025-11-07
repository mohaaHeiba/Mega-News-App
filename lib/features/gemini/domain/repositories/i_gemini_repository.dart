abstract class IGeminiRepository {
  /// بيبعت prompt لـ Gemini ويرجع الرد كـ String.
  /// هيرمي ApiException لو حصل مشكلة.
  Future<String> generateText(String prompt);
}
