import 'package:flutter/material.dart';

class ShowSearchPage extends StatelessWidget {
  const ShowSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search News')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          autofocus: true, // Automatically open keyboard
          decoration: InputDecoration(
            hintText: 'Search news, topics, or sources...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: const Icon(Icons.mic),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Theme.of(context).cardColor,
          ),
          onSubmitted: (value) {
            // Handle search logic here
            print('Searching for: $value');
          },
        ),
      ),
    );
  }
}
