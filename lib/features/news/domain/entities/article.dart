class Article {
  final String title;
  final String description;
  final String fullContent;
  final String scrapedContent; // New field for web-scraped content
  final String imageUrl;
  final String url;
  final String date;
  final bool isContentScraped; // Flag to indicate if content has been scraped

  const Article({
    required this.title,
    required this.description,
    required this.fullContent,
    this.scrapedContent = '',
    required this.imageUrl,
    required this.url,
    required this.date,
    this.isContentScraped = false,
  });

  // Method to get the best available content
  String get bestContent {
    if (scrapedContent.isNotEmpty && scrapedContent.length > fullContent.length) {
      return scrapedContent;
    }
    return fullContent.isNotEmpty ? fullContent : description;
  }

  // Check if article has substantial content
  bool get hasSubstantialContent {
    return bestContent.split(' ').length > 100;
  }

  // Create a copy with scraped content
  Article copyWithScrapedContent(String scrapedContent) {
    return Article(
      title: title,
      description: description,
      fullContent: fullContent,
      scrapedContent: scrapedContent,
      imageUrl: imageUrl,
      url: url,
      date: date,
      isContentScraped: true,
    );
  }
}
