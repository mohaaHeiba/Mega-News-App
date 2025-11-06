import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:mega_news_app/features/home/presentation/controller/home_controller.dart';

class Summrization extends StatefulWidget {
  const Summrization({super.key});

  @override
  State<Summrization> createState() => _SummrizationState();
}

class _SummrizationState extends State<Summrization> {
  final HomeController _ctrl = Get.find<HomeController>();
  int _hours = 24;

  void _requestSummary() async {
    await _ctrl.summarizeCategory(hours: _hours);
    // scroll to results or show a SnackBar if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Summarization'), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Obx(() {
              final cats = _ctrl.categories;
              final selected = _ctrl.selectedCategory.value;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: cats.map((c) {
                  final v = c['value'] as String;
                  return ChoiceChip(
                    label: Text(c['label'] as String),
                    selected: selected == v,
                    onSelected: (_) => _ctrl.changeCategory(v),
                  );
                }).toList(),
              );
            }),
            const SizedBox(height: 16),
            Text('Period', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _hours == 12
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    onPressed: () => setState(() => _hours = 12),
                    child: const Text('Last 12 hours'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _hours == 24
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    onPressed: () => setState(() => _hours = 24),
                    child: const Text('Last 24 hours'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.auto_awesome),
                    label: Obx(
                      () => Text(
                        _ctrl.isSummarizing.value
                            ? 'Summarizing...'
                            : 'Generate Summary',
                      ),
                    ),
                    onPressed: _ctrl.isSummarizing.value
                        ? null
                        : _requestSummary,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    _ctrl.summary.value = '';
                  },
                  child: const Icon(Icons.clear),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Obx(() {
                if (_ctrl.isSummarizing.value) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Generating summary...'),
                      ],
                    ),
                  );
                }

                final txt = _ctrl.summary.value;
                if (txt.isEmpty) {
                  return Center(
                    child: Text(
                      'No summary yet. Tap Generate to create a brief summary for the selected category and period.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [Expanded(child: SelectableText(txt))],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: txt));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Copied summary to clipboard',
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.copy),
                                label: const Text('Copy'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
