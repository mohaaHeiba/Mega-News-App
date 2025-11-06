import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:mega_news_app/features/home/presentation/controller/home_controller.dart';
import 'package:mega_news_app/features/home/domain/entities/article.dart';

class ArticleSearchDelegate extends SearchDelegate<Article?> {
  final HomeController ctrl;
  final stt.SpeechToText _stt = stt.SpeechToText();
  bool _isListening = false;
  final ValueNotifier<double> _soundLevel = ValueNotifier<double>(0.0);
  bool _disposed = false;

  ArticleSearchDelegate(this.ctrl);

  Future<void> _startListening() async {
    final ctx = navigator?.context;
    bool available = false;
    try {
      available = await _stt.initialize(onStatus: (_) {}, onError: (_) {});
    } catch (_) {
      available = false;
    }
    if (!available) {
      if (ctx != null) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(
            content: Text('Microphone not available or permission denied.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }
    _isListening = true;
    _soundLevel.value = 1.0;
    _stt.listen(
      onResult: (result) {
        if (result.finalResult || result.recognizedWords.isNotEmpty) {
          query = result.recognizedWords;
          showResults(navigator!.context);
        }
      },
      onSoundLevelChange: (level) {
        _soundLevel.value = level;
      },
    );
  }

  void _stopListening() {
    if (_isListening) _stt.stop();
    _isListening = false;
    _soundLevel.value = 0.0;
  }

  List<Article> _filter(String q) {
    final lower = q.toLowerCase();
    return ctrl.articles.where((a) {
      final title = (a.title).toLowerCase();
      final summary = (a.summary).toLowerCase();
      return title.contains(lower) || summary.contains(lower);
    }).toList();
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = '';
            showSuggestions(context);
          }
        },
      ),
      ValueListenableBuilder<double>(
        valueListenable: _soundLevel,
        builder: (context, level, _) {
          final double normalized = (level.clamp(0.0, 30.0) / 30.0);
          final double scale = _isListening ? (1.0 + normalized * 0.6) : 1.0;
          return IconButton(
            icon: Transform.scale(
              scale: scale,
              child: Icon(_isListening ? Icons.mic : Icons.mic_none),
            ),
            onPressed: () {
              if (!_isListening) {
                _startListening();
              } else {
                _stopListening();
              }
            },
          );
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        _stopListening();
        close(context, null);
      },
    );
  }

  @override
  void close(BuildContext context, Article? result) {
    try {
      _stopListening();
      if (!_disposed) {
        _soundLevel.dispose();
        _disposed = true;
      }
    } catch (_) {}
    super.close(context, result);
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = _filter(query);
    if (results.isEmpty) return const Center(child: Text('No results'));
    final list = ListView.separated(
      itemCount: results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final a = results[index];
        return ListTile(
          leading: a.image.isNotEmpty
              ? Image.network(a.image, width: 60, fit: BoxFit.cover)
              : null,
          title: Text(a.title),
          subtitle: Text(a.summary),
          onTap: () {
            _stopListening();
            close(context, a);
          },
        );
      },
    );
    return _wrapWithListeningOverlay(context, list);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty ? [] : _filter(query).take(6).toList();
    final list = ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final a = suggestions[index];
        return ListTile(
          title: Text(a.title),
          onTap: () {
            query = a.title;
            showResults(context);
          },
        );
      },
    );
    return _wrapWithListeningOverlay(context, list);
  }

  Widget _wrapWithListeningOverlay(BuildContext context, Widget child) {
    if (!_isListening) return child;
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            ignoring: true,
            child: Container(color: Colors.black.withOpacity(0.25)),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 24,
          child: Center(
            child: _MicIndicator(
              soundLevel: _soundLevel,
              isListening: _isListening,
            ),
          ),
        ),
      ],
    );
  }
}

class _MicIndicator extends StatelessWidget {
  final ValueNotifier<double> soundLevel;
  final bool isListening;
  const _MicIndicator({required this.soundLevel, required this.isListening});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: soundLevel,
      builder: (context, level, _) {
        final double normalized = (level.clamp(0.0, 30.0) / 30.0);
        final double scale = isListening ? (1.0 + normalized * 0.6) : 1.0;
        final double translateY = isListening ? -normalized * 10 : 0.0;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          transform: Matrix4.identity()
            ..translate(0.0, translateY)
            ..scale(scale),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(36),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Icon(
              Icons.mic,
              color: isListening ? Colors.redAccent : Colors.grey[700],
              size: 28,
            ),
          ),
        );
      },
    );
  }
}
