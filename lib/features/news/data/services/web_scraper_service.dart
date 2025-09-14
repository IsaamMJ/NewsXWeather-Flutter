// lib/features/news/data/services/web_scraper_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';

class WebScraperService {
  final http.Client httpClient;

  // Cache for scraped articles
  static final Map<String, String> _scrapedContentCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const int _cacheExpiryHours = 24; // Cache for 24 hours

  WebScraperService(this.httpClient);

  Future<String> scrapeFullArticle(String url) async {
    try {
      // Check cache first
      final cachedContent = _getCachedContent(url);
      if (cachedContent != null) {
        print('[WebScraper] Using cached content for: $url');
        return cachedContent;
      }

      print('[WebScraper] Scraping: $url');

      final response = await httpClient.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.5',
          'Accept-Encoding': 'gzip, deflate',
          'Connection': 'keep-alive',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch article: ${response.statusCode}');
      }

      final fullContent = _extractArticleContent(response.body, url);

      // Cache the result
      _cacheContent(url, fullContent);

      return fullContent;

    } catch (e) {
      print('[WebScraper] Error scraping $url: $e');
      return 'Failed to load full article content. Please try opening in browser.';
    }
  }

  String _extractArticleContent(String html, String url) {
    final document = html_parser.parse(html);

    // Try multiple extraction methods
    String content = _extractBySiteSpecificRules(document, url);

    if (content.isEmpty) {
      content = _extractByCommonSelectors(document);
    }

    if (content.isEmpty) {
      content = _extractByGenericMethod(document);
    }

    // Clean and format the content
    return _cleanAndFormatContent(content);
  }

  String _extractBySiteSpecificRules(Document document, String url) {
    final host = Uri.parse(url).host.toLowerCase();

    // BBC News
    if (host.contains('bbc.co.uk') || host.contains('bbc.com')) {
      final content = document.querySelector('[data-component="text-block"]')?.text ??
          document.querySelector('.story-body__inner')?.text ??
          document.querySelector('[data-component="body-text"]')?.text ??
          document.querySelector('.gel-body-copy')?.text ?? '';
      if (content.isNotEmpty) return content;
    }

    // CNN
    if (host.contains('cnn.com')) {
      final content = document.querySelector('.zn-body__paragraph')?.text ??
          document.querySelector('.pg-rail-tall__body')?.text ??
          document.querySelector('.l-container')?.text ?? '';
      if (content.isNotEmpty) return content;
    }

    // Reuters
    if (host.contains('reuters.com')) {
      final content = document.querySelector('[data-testid="paragraph"]')?.text ??
          document.querySelector('.StandardArticleBody_body')?.text ??
          document.querySelector('.ArticleBodyWrapper')?.text ?? '';
      if (content.isNotEmpty) return content;
    }

    // TechCrunch
    if (host.contains('techcrunch.com')) {
      final content = document.querySelector('.entry-content')?.text ??
          document.querySelector('.article-entry')?.text ?? '';
      if (content.isNotEmpty) return content;
    }

    // Guardian
    if (host.contains('theguardian.com')) {
      final content = document.querySelector('.content__article-body')?.text ??
          document.querySelector('[data-gu-name="body"]')?.text ?? '';
      if (content.isNotEmpty) return content;
    }

    // Business Insider
    if (host.contains('businessinsider.com')) {
      final content = document.querySelector('.content-lock-content')?.text ??
          document.querySelector('.post-content')?.text ?? '';
      if (content.isNotEmpty) return content;
    }

    return '';
  }

  String _extractByCommonSelectors(Document document) {
    // Common article selectors used by many news sites
    final selectors = [
      'article',
      '[role="main"] article',
      '.article-content',
      '.entry-content',
      '.post-content',
      '.article-body',
      '.story-content',
      '.content-body',
      '.article-text',
      '[data-module="ArticleBody"]',
      '.article__body',
      '.story-body',
      '.post-body',
      'main article',
      '[itemprop="articleBody"]',
    ];

    for (String selector in selectors) {
      final element = document.querySelector(selector);
      if (element != null) {
        final content = _extractTextFromElement(element);
        if (content.split(' ').length > 50) { // Only return if substantial content
          return content;
        }
      }
    }

    return '';
  }

  String _extractByGenericMethod(Document document) {
    // Remove unwanted elements first
    final unwantedSelectors = [
      'script', 'style', 'nav', 'header', 'footer', 'aside',
      '.advertisement', '.ad', '.ads', '.social-share',
      '.comments', '.comment', '.sidebar', '.widget',
      '.related-articles', '.recommended', '.newsletter',
      '.cookie-notice', '.popup', '.modal'
    ];

    for (String selector in unwantedSelectors) {
      document.querySelectorAll(selector).forEach((element) {
        element.remove();
      });
    }

    // Try to find the main content area
    final mainContent = document.querySelector('main') ??
        document.querySelector('[role="main"]') ??
        document.querySelector('.main') ??
        document.querySelector('#main') ??
        document.querySelector('.container') ??
        document.body;

    if (mainContent != null) {
      // Look for paragraphs within the main content
      final paragraphs = mainContent.querySelectorAll('p');
      if (paragraphs.isNotEmpty) {
        final content = paragraphs.map((p) => p.text.trim())
            .where((text) => text.isNotEmpty && text.length > 20)
            .join('\n\n');

        if (content.split(' ').length > 30) {
          return content;
        }
      }
    }

    return 'Unable to extract full article content.';
  }

  String _extractTextFromElement(Element element) {
    // Remove unwanted child elements
    final unwantedTags = ['script', 'style', 'nav', 'aside', '.ad', '.advertisement'];
    for (String tag in unwantedTags) {
      element.querySelectorAll(tag).forEach((el) => el.remove());
    }

    // Extract text from paragraphs and headers
    final textElements = element.querySelectorAll('p, h1, h2, h3, h4, h5, h6, li');
    final textParts = textElements.map((el) => el.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    return textParts.join('\n\n');
  }

  String _cleanAndFormatContent(String content) {
    if (content.isEmpty) return content;

    return content
    // Remove extra whitespace
        .replaceAll(RegExp(r'\n\s*\n\s*\n'), '\n\n')
        .replaceAll(RegExp(r'\s+'), ' ')
    // Remove unwanted phrases
        .replaceAll(RegExp(r'Click here to.*?(?=\n|$)'), '')
        .replaceAll(RegExp(r'Subscribe to.*?(?=\n|$)'), '')
        .replaceAll(RegExp(r'Follow us on.*?(?=\n|$)'), '')
        .replaceAll(RegExp(r'Read more:.*?(?=\n|$)'), '')
    // Clean up HTML entities
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&nbsp;', ' ')
    // Remove excessive line breaks
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  // Cache management
  String? _getCachedContent(String url) {
    if (!_scrapedContentCache.containsKey(url) || !_cacheTimestamps.containsKey(url)) {
      return null;
    }

    final cacheTime = _cacheTimestamps[url]!;
    final now = DateTime.now();
    final timeDifference = now.difference(cacheTime).inHours;

    if (timeDifference < _cacheExpiryHours) {
      return _scrapedContentCache[url];
    }

    // Remove expired cache
    _scrapedContentCache.remove(url);
    _cacheTimestamps.remove(url);
    return null;
  }

  void _cacheContent(String url, String content) {
    _scrapedContentCache[url] = content;
    _cacheTimestamps[url] = DateTime.now();

    // Clean up old cache entries (keep only last 50 articles)
    if (_scrapedContentCache.length > 50) {
      final oldestKey = _cacheTimestamps.entries
          .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
          .key;
      _scrapedContentCache.remove(oldestKey);
      _cacheTimestamps.remove(oldestKey);
    }
  }

  // Method to clear cache
  static void clearCache() {
    _scrapedContentCache.clear();
    _cacheTimestamps.clear();
  }

  // Method to get cache status
  static Map<String, String> getCacheStatus() {
    final status = <String, String>{};
    for (final entry in _cacheTimestamps.entries) {
      final age = DateTime.now().difference(entry.value).inHours;
      final contentLength = _scrapedContentCache[entry.key]?.length ?? 0;
      status[entry.key] = '$contentLength chars, ${age}h old';
    }
    return status;
  }
}