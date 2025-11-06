class Article {
  final String title;
  final String summary;
  final String image;
  final String time;

  Article({
    required this.title,
    required this.summary,
    required this.image,
    required this.time,
  });

  factory Article.fromMap(Map<String, dynamic> m) => Article(
    title: m['title'] ?? 'No Title',
    summary: m['summary'] ?? '',
    image: m['image'] ?? 'https://picsum.photos/600/350',
    time: m['time'] ?? '',
  );

  Map<String, dynamic> toMap() => {
    'title': title,
    'summary': summary,
    'image': image,
    'time': time,
  };
}
