import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:mega_news_app/features/home/presentation/controller/home_controller.dart';
import 'package:mega_news_app/features/home/presentation/widgets/article_tile.dart';
import 'package:mega_news_app/features/home/domain/entities/article.dart';
import 'package:mega_news_app/features/home/presentation/widgets/voice_search.dart';

/// A polished search results page.
///
/// Usage:
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => ShowSearchPage(query: 'flutter'),
/// ));
class ShowSearchPage extends StatelessWidget {
  final String query;
  final List<Article>? articles;

  const ShowSearchPage({super.key, this.query = '', this.articles});

  List<Article> _filter(List<Article> src, String q) {
    if (q.isEmpty) return src;
    final lower = q.toLowerCase();
    return src.where((a) {
      return a.title.toLowerCase().contains(lower) ||
          a.summary.toLowerCase().contains(lower);
    }).toList();
  }

  Widget _buildEmpty(BuildContext context, String q) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 72,
              color: Theme.of(context).hintColor,
            ),
            const SizedBox(height: 16),
            Text(
              q.isEmpty ? 'No query entered' : 'No results for "$q"',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Try different keywords or remove filters to broaden your search.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerList(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: 92,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: 6,
    );
  }

  @override
  Widget build(BuildContext context) {
    final HomeController ctrl = Get.find<HomeController>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Search', style: Theme.of(context).textTheme.titleLarge),
            if (query.isNotEmpty)
              Text(
                '"$query"',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
              ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic_none),
            onPressed: () async {
              final res = await showSearch<Article?>(
                context: context,
                delegate: ArticleSearchDelegate(ctrl),
              );
              if (res != null) {
                // optionally navigate to details later; for now just show snackbar
                if (context.mounted)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Selected: ${res.title}')),
                  );
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return _buildShimmerList(context);
        }

        final source = articles ?? ctrl.articles;
        final results = _filter(source, query);

        return RefreshIndicator(
          onRefresh: () => ctrl.fetchNews(),
          child: results.isEmpty
              ? _buildEmpty(context, query)
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemBuilder: (context, index) {
                    final a = results[index];
                    return ArticleTile(article: a);
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: results.length,
                ),
        );
      }),
    );
  }
}
