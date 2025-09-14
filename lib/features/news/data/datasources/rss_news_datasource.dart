// lib/features/news/data/datasources/rss_news_datasource.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../../domain/entities/article.dart';
import '../models/article_model.dart';

class RssNewsDataSource {
  final http.Client httpClient;

  // Simple in-memory cache
  static final Map<String, List<Article>> _cache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const int _cacheExpiryMinutes = 15; // Cache for 15 minutes

  RssNewsDataSource(this.httpClient);

  // RSS feed URLs for different categories
  static const Map<String, List<String>> _rssFeeds = {
    'business': [
      'https://feeds.bbci.co.uk/news/business/rss.xml',
      'https://feeds.reuters.com/reuters/businessNews',
      'https://rss.cnn.com/rss/money_news_international.rss',
      'https://feeds.feedburner.com/businessinsider',
    ],
    'technology': [
      'https://feeds.bbci.co.uk/news/technology/rss.xml',
      'https://techcrunch.com/feed/',
      'https://rss.cnn.com/rss/edition_technology.rss',
      'https://feeds.feedburner.com/oreilly/radar',
    ],
    'health': [
      'https://feeds.bbci.co.uk/news/health/rss.xml',
      'https://feeds.reuters.com/reuters/healthNews',
      'https://rss.cnn.com/rss/edition_health.rss',
      'https://feeds.webmd.com/rss/rss.aspx?RSSSource=RSS_PUBLIC',
    ],
    'sports': [
      'https://feeds.bbci.co.uk/sport/rss.xml',
      'https://feeds.reuters.com/reuters/sportsNews',
      'https://rss.cnn.com/rss/edition_sport.rss',
      'https://www.espn.com/espn/rss/news',
    ],
    'entertainment': [
      'https://feeds.bbci.co.uk/news/entertainment_and_arts/rss.xml',
      'https://feeds.reuters.com/reuters/entertainmentNews',
      'https://rss.cnn.com/rss/edition_entertainment.rss',
      'https://feeds.feedburner.com/variety/headlines',
    ],
    'science': [
      'https://feeds.bbci.co.uk/news/science_and_environment/rss.xml',
      'https://feeds.reuters.com/reuters/scienceNews',
      'https://rss.sciam.com/ScientificAmerican-Global',
      'https://feeds.feedburner.com/NationalGeographic',
    ],
    'general': [
      'https://feeds.bbci.co.uk/news/rss.xml',
      'https://feeds.reuters.com/reuters/topNews',
      'https://rss.cnn.com/rss/edition.rss',
      'https://feeds.feedburner.com/TheHuffingtonPost',
    ],
  };

  Future<List<Article>> fetchNews(String category, int page) async {
    try {
      // Check cache first
      final cachedArticles = _getCachedArticles(category);
      if (cachedArticles != null) {
        print('[RssNewsDataSource] Using cached data for $category');
        return _paginateArticles(cachedArticles, page);
      }

      final feedUrls = _rssFeeds[category] ?? _rssFeeds['general']!;
      List<Article> allArticles = [];
      int successfulFeeds = 0;

      // Fetch from ALL RSS feeds for the category with timeout
      for (String feedUrl in feedUrls) {
        try {
          print('[RssNewsDataSource] Fetching from: $feedUrl');
          final articles = await _fetchFromSingleFeed(feedUrl).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('[RssNewsDataSource] Timeout for $feedUrl');
              return <Article>[];
            },
          );

          if (articles.isNotEmpty) {
            allArticles.addAll(articles);
            successfulFeeds++;
            print('[RssNewsDataSource] Got ${articles.length} articles from $feedUrl');
          }

        } catch (e) {
          print('[RssNewsDataSource] Error fetching from $feedUrl: $e');
          // Continue with other feeds if one fails
        }
      }

      print('[RssNewsDataSource] Total articles fetched: ${allArticles.length} from $successfulFeeds feeds');

      // If no feeds worked, return cached data even if expired
      if (allArticles.isEmpty) {
        print('[RssNewsDataSource] All feeds failed, checking expired cache');
        final expiredCache = _getExpiredCachedArticles(category);
        if (expiredCache != null) {
          return _paginateArticles(expiredCache, page);
        }
      }

      // Remove duplicates and sort by date
      final uniqueArticles = _removeDuplicates(allArticles);
      uniqueArticles.sort((a, b) => b.date.compareTo(a.date));

      // Cache the results
      _cacheArticles(category, uniqueArticles);

      return _paginateArticles(uniqueArticles, page);

    } catch (e) {
      print('[RssNewsDataSource] Error: $e');

      // Return cached data as fallback
      final fallbackArticles = _getExpiredCachedArticles(category);
      if (fallbackArticles != null) {
        return _paginateArticles(fallbackArticles, page);
      }

      return [];
    }
  }

  Future<List<Article>> _fetchFromSingleFeed(String feedUrl) async {
    final response = await httpClient.get(
      Uri.parse(feedUrl),
      headers: {
        'User-Agent': 'SkySeed-News-App/1.0',
        'Accept': 'application/rss+xml, application/xml, text/xml',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load RSS feed: ${response.statusCode}');
    }

    return _parseRssFeed(response.body, feedUrl);
  }

  List<Article> _parseRssFeed(String xmlString, String feedUrl) {
    try {
      final document = XmlDocument.parse(xmlString);
      final items = document.findAllElements('item');

      return items.map((item) {
        try {
          final title = _getElementText(item, 'title');
          final description = _getElementText(item, 'description');
          final link = _getElementText(item, 'link');
          final pubDate = _getElementText(item, 'pubDate');

          // Skip if essential fields are missing
          if (title.isEmpty || link.isEmpty) {
            return null;
          }

          // Use enhanced content extraction
          final fullContent = _extractFullContent(item, description);

          return ArticleModel(
            title: _cleanText(title),
            description: _cleanText(_stripHtml(description.isNotEmpty ? description : fullContent)),
            fullContent: fullContent,
            imageUrl: '', // No images needed
            url: link,
            date: _formatDate(pubDate),
          );
        } catch (e) {
          print('[RssNewsDataSource] Error parsing item from $feedUrl: $e');
          return null;
        }
      }).where((article) => article != null).cast<Article>().toList();

    } catch (e) {
      print('[RssNewsDataSource] Error parsing XML from $feedUrl: $e');
      throw Exception('Failed to parse RSS XML: $e');
    }
  }

  // Enhanced content extraction method
  String _extractFullContent(XmlElement item, String description) {
    String fullContent = '';

    // 1. Try content:encoded (usually has full content)
    final contentEncoded = _getElementText(item, 'content:encoded');
    if (contentEncoded.isNotEmpty && contentEncoded.length > description.length) {
      fullContent = contentEncoded;
    }

    // 2. Try content:full
    if (fullContent.isEmpty) {
      final contentFull = _getElementText(item, 'content:full');
      if (contentFull.isNotEmpty) {
        fullContent = contentFull;
      }
    }

    // 3. Try summary with higher word count
    if (fullContent.isEmpty) {
      final summary = _getElementText(item, 'summary');
      if (summary.isNotEmpty && summary.length > description.length) {
        fullContent = summary;
      }
    }

    // 4. Try combining description with summary
    if (fullContent.isEmpty && description.isNotEmpty) {
      final summary = _getElementText(item, 'summary');
      if (summary.isNotEmpty && summary != description) {
        fullContent = '$description\n\n$summary';
      }
    }

    // 5. If still empty, use description
    if (fullContent.isEmpty) {
      fullContent = description;
    }

    // 6. Enhance content if it's too short
    if (fullContent.split(' ').length < 50) {
      fullContent = _enhanceShortContent(fullContent, item);
    }

    return fullContent;
  }

  String _enhanceShortContent(String content, XmlElement item) {
    List<String> contentParts = [content];

    // Try to get additional content from various elements
    final additionalFields = [
      'content',
      'text',
      'body',
      'article',
      'fulltext'
    ];

    for (String field in additionalFields) {
      final additionalContent = _getElementText(item, field);
      if (additionalContent.isNotEmpty &&
          additionalContent != content &&
          additionalContent.length > 20) {
        contentParts.add(additionalContent);
      }
    }

    // Combine all content parts
    final enhancedContent = contentParts.join('\n\n');

    // If still too short, add a notice
    if (enhancedContent.split(' ').length < 30) {
      return enhancedContent + '\n\n[This appears to be a summary. Full article available at source.]';
    }

    return enhancedContent;
  }

  String _getElementText(XmlElement parent, String tagName) {
    try {
      final elements = parent.findElements(tagName);
      if (elements.isNotEmpty) {
        return elements.first.text.trim();
      }

      // Try with namespace prefixes
      final namespacedElements = parent.findAllElements(tagName);
      if (namespacedElements.isNotEmpty) {
        return namespacedElements.first.text.trim();
      }

      return '';
    } catch (e) {
      return '';
    }
  }

  String _cleanText(String text) {
    return text
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'&nbsp;'), ' ')
        .replaceAll(RegExp(r'&amp;'), '&')
        .replaceAll(RegExp(r'&lt;'), '<')
        .replaceAll(RegExp(r'&gt;'), '>')
        .replaceAll(RegExp(r'&quot;'), '"')
        .replaceAll(RegExp(r'&#039;'), "'")
        .replaceAll(RegExp(r'&apos;'), "'")
        .replaceAll(RegExp(r'&ndash;'), '–')
        .replaceAll(RegExp(r'&mdash;'), '—')
        .trim();
  }

  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'&nbsp;'), ' ')
        .trim();
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) {
      return DateTime.now().toIso8601String();
    }

    try {
      // Try ISO format first
      final date = DateTime.parse(dateString);
      return date.toIso8601String();
    } catch (e) {
      try {
        // Handle RFC 2822 format (common in RSS)
        final cleanedDate = dateString.replaceAll(RegExp(r'\s+'), ' ').trim();
        final parts = cleanedDate.split(' ');

        if (parts.length >= 4) {
          final day = int.tryParse(parts[1]) ?? 1;
          final month = _getMonthNumber(parts[2]);
          final year = int.tryParse(parts[3]) ?? DateTime.now().year;

          final date = DateTime(year, month, day);
          return date.toIso8601String();
        }
      } catch (e2) {
        print('[RssNewsDataSource] Date parsing error for "$dateString": $e2');
      }

      // Fallback to current time
      return DateTime.now().toIso8601String();
    }
  }

  int _getMonthNumber(String monthName) {
    final cleanMonth = monthName.toLowerCase().substring(0, 3);
    const months = {
      'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
      'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
    };
    return months[cleanMonth] ?? 1;
  }

  List<Article> _removeDuplicates(List<Article> articles) {
    final seen = <String>{};
    return articles.where((article) {
      // Create a more robust duplicate detection key
      final key = '${article.title.toLowerCase()}_${article.url}'.replaceAll(RegExp(r'\s+'), '');
      if (seen.contains(key)) {
        return false;
      }
      seen.add(key);
      return true;
    }).toList();
  }

  // Cache management methods
  List<Article>? _getCachedArticles(String category) {
    if (!_cache.containsKey(category) || !_cacheTimestamps.containsKey(category)) {
      return null;
    }

    final cacheTime = _cacheTimestamps[category]!;
    final now = DateTime.now();
    final timeDifference = now.difference(cacheTime).inMinutes;

    if (timeDifference < _cacheExpiryMinutes) {
      return _cache[category];
    }

    return null;
  }

  List<Article>? _getExpiredCachedArticles(String category) {
    return _cache[category];
  }

  void _cacheArticles(String category, List<Article> articles) {
    _cache[category] = articles;
    _cacheTimestamps[category] = DateTime.now();

    // Clean up old cache entries (keep only last 10 categories)
    if (_cache.length > 10) {
      final oldestKey = _cacheTimestamps.entries
          .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
          .key;
      _cache.remove(oldestKey);
      _cacheTimestamps.remove(oldestKey);
    }
  }

  List<Article> _paginateArticles(List<Article> articles, int page) {
    final startIndex = (page - 1) * 20;
    final endIndex = startIndex + 20;

    if (startIndex >= articles.length) return [];

    return articles.sublist(
        startIndex,
        endIndex > articles.length ? articles.length : endIndex
    );
  }

  // Method to clear cache (useful for refresh)
  static void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  // Method to get cache status (useful for debugging)
  static Map<String, String> getCacheStatus() {
    final status = <String, String>{};
    for (final entry in _cacheTimestamps.entries) {
      final age = DateTime.now().difference(entry.value).inMinutes;
      status[entry.key] = '${_cache[entry.key]?.length ?? 0} articles, ${age}min old';
    }
    return status;
  }
}