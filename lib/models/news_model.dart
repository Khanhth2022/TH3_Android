class Article {
  final String title;
  final String? description;
  final String? content;
  final String? url;
  final String? sourceName;
  final String? urlToImage;
  final String? publishedAt;

  Article({
    required this.title,
    this.description,
    this.content,
    this.url,
    this.sourceName,
    this.urlToImage,
    this.publishedAt,
  });

  // Factory constructor để từ JSON
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'Không có tiêu đề',
      description: json['description'],
      content: json['content'],
      url: json['url'],
      sourceName: json['source']?['name'],
      urlToImage: json['urlToImage'],
      publishedAt: json['publishedAt'],
    );
  }

  // Chuyển đổi sang JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'content': content,
      'url': url,
      'source': {'name': sourceName},
      'urlToImage': urlToImage,
      'publishedAt': publishedAt,
    };
  }
}
