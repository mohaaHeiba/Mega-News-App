import 'package:get/get.dart';
import 'package:mega_news_app/features/home/domain/entities/article.dart';

class HomeController extends GetxController {
  // 1. Loading State
  final isLoading = true.obs;

  // 2. Category State
  final selectedCategory = 'general'.obs;
  final categories = const [
    {'label': 'General', 'value': 'general'},
    {'label': 'Sports', 'value': 'sports'},
    {'label': 'Technology', 'value': 'technology'},
    {'label': 'Business', 'value': 'business'},
    {'label': 'Health', 'value': 'health'},
  ];

  // 3. Articles List
  final articles = <Article>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchNews(); // Load initial data
  }

  // 4. Methods
  Future<void> fetchNews() async {
    isLoading(true);
    // Simulate a network delay
    await Future.delayed(const Duration(seconds: 2));

    // Load mock data
    articles.value = _getMockArticles(selectedCategory.value);
    isLoading(false);
  }

  void changeCategory(String newValue) {
    selectedCategory(newValue);
    fetchNews(); // Refetch news for the new category
  }

  // --- MOCK DATA GENERATOR ---
  List<Article> _getMockArticles(String category) {
    // Return different data based on category for realism
    if (category == 'sports') {
      return [
        Article(
          title: 'Unbelievable Goal Wins the Championship',
          summary:
              'A last-minute goal secures the cup in a stunning final match.',
          image: 'https://picsum.photos/seed/sports1/400/300',
          time: '2h ago',
          source: 'Sports Weekly',
        ),
        Article(
          title: 'Team Signs New Star Player',
          summary:
              'The transfer market is buzzing with this new record-breaking deal.',
          image: 'https://picsum.photos/seed/sports2/400/300',
          time: '5h ago',
          source: 'Transfer News',
        ),
      ];
    }

    // Default/General data
    return List.generate(
      8,
      (index) => Article(
        title: 'Mock Article $category ${index + 1}: The Future of News',
        summary:
            'This is a mock summary for article ${index + 1}. The content is placeholder.',
        image:
            'https://picsum.photos/seed/$category$index/400/300', // Different image per article
        time: '${(index + 1) * 15}m ago',
        source: 'Mock News Agency',
      ),
    );
  }
}
