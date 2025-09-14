// lib/features/news/presentation/widgets/news_widget.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/news_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/strings.dart';

class NewsWidget extends StatelessWidget {
  const NewsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NewsController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 100),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.articles.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.newspaper_outlined,
                size: 64,
                color: AppColors.getTextSecondary(context),
              ),
              const SizedBox(height: 16),
              Text(
                Strings.noNewsAvailable,
                style: TextStyle(
                  color: AppColors.getTextSecondary(context),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: controller.refreshNews,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.getAccent(context),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshNews,
        color: AppColors.getAccent(context),
        child: Column(
          children: [
            // Enhanced news header with article count
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.getAccent(context).withOpacity(0.8),
                      AppColors.getAccent(context).withOpacity(0.4),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.getAccent(context).withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.newspaper,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Latest News",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${controller.getArticleCount()} articles • ${controller.lastUpdateText}",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "RSS",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Clean text-only news articles
            ...controller.articles.map((article) {
              return GestureDetector(
                onTap: () => controller.openArticle(article),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.getCardColor(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.getAccent(context).withOpacity(0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.getAccent(context).withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Source and category header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getSourceColor(article.url).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _getSourceColor(article.url).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _getSourceName(article.url),
                                style: TextStyle(
                                  color: _getSourceColor(article.url),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: AppColors.getTextSecondary(context),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatTimeAgo(article.date),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.getTextSecondary(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Article title
                        Text(
                          article.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            color: AppColors.getTextPrimary(context),
                            height: 1.35,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 8),

                        // Article description
                        if (article.description.isNotEmpty)
                          Text(
                            article.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.getTextSecondary(context),
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),

                        const SizedBox(height: 12),

                        // Bottom row with read more indicator
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      _getSourceColor(article.url).withOpacity(0.6),
                                      _getSourceColor(article.url).withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: AppColors.getAccent(context),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Read Article',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.getAccent(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),

            // Bottom spacing
            const SizedBox(height: 20),
          ],
        ),
      );
    });
  }

  String _getSourceName(String url) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host.toLowerCase();

      if (host.contains('bbc')) return 'BBC';
      if (host.contains('reuters')) return 'Reuters';
      if (host.contains('techcrunch')) return 'TechCrunch';
      if (host.contains('cnn')) return 'CNN';
      if (host.contains('guardian')) return 'Guardian';
      if (host.contains('espn')) return 'ESPN';
      if (host.contains('businessinsider')) return 'Business Insider';
      if (host.contains('variety')) return 'Variety';
      if (host.contains('webmd')) return 'WebMD';
      if (host.contains('sciam') || host.contains('scientific')) return 'Scientific American';
      if (host.contains('nationalgeographic')) return 'Nat Geo';
      if (host.contains('huffpost') || host.contains('huffington')) return 'HuffPost';

      final parts = host.split('.');
      if (parts.length >= 2) {
        return parts[parts.length - 2].toUpperCase();
      }

      return 'News';
    } catch (e) {
      return 'News';
    }
  }

  Color _getSourceColor(String url) {
    final host = url.toLowerCase();

    if (host.contains('bbc')) return const Color(0xFFBB1919);
    if (host.contains('reuters')) return const Color(0xFFFF6200);
    if (host.contains('techcrunch')) return const Color(0xFF0F9D58);
    if (host.contains('cnn')) return const Color(0xFFCC0000);
    if (host.contains('guardian')) return const Color(0xFF052962);
    if (host.contains('espn')) return const Color(0xFFFF0000);
    if (host.contains('businessinsider')) return const Color(0xFF0066CC);
    if (host.contains('variety')) return const Color(0xFF9C27B0);
    if (host.contains('webmd')) return const Color(0xFF00A651);
    if (host.contains('sciam') || host.contains('scientific')) return const Color(0xFF4285F4);
    if (host.contains('nationalgeographic')) return const Color(0xFFFFCC00);
    if (host.contains('huffpost') || host.contains('huffington')) return const Color(0xFF69BE28);

    return const Color(0xFF4285F4); // Default blue
  }

  String _formatTimeAgo(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${(difference.inDays / 7).floor()}w ago';
      }
    } catch (e) {
      return 'Now';
    }
  }
}