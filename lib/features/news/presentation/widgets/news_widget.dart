import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../controllers/news_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/strings.dart'; // Import the centralized strings

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
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 100),
          child: Center(child: Text(Strings.noNewsAvailable)), // Use centralized string
        );
      }

      // Mood caption
      String moodCaption = '';
      switch (controller.mood.value) {
        case 'cold':
          moodCaption = Strings.moodCaptionCold;
          break;
        case 'hot':
          moodCaption = Strings.moodCaptionHot;
          break;
        case 'warm':
          moodCaption = Strings.moodCaptionWarm;
          break;
        default:
          moodCaption = Strings.moodCaptionDefault;
      }

      return Column(
        children: [
          // Mood caption
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.getAccent(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                moodCaption,
                style: TextStyle(
                  color: AppColors.getTextPrimary(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // News articles
          ...controller.articles.map((article) {
            return GestureDetector(
              onTap: () async {
                final articleUrl = article.url;
                if (articleUrl.isNotEmpty) {
                  await controller.launchArticleUrl(articleUrl);
                } else {
                  Get.snackbar(Strings.error, Strings.errorNoUrl, snackPosition: SnackPosition.BOTTOM);
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.getCardColor(context),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.getAccent(context).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(4, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: Image.network(
                        article.imageUrl,
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => SizedBox(
                          height: 180,
                          child: Center(
                            child: Icon(Icons.broken_image, color: AppColors.getTextSecondary(context)),
                          ),
                        ),
                      ),
                    ),

                    // Text content
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: AppColors.getTextPrimary(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            article.description.isEmpty
                                ? Strings.noDescriptionAvailable
                                : article.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.getTextSecondary(context),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            article.date,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.getTextSecondary(context).withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      );
    });
  }
}

class InAppWebViewPage extends StatelessWidget {
  final String url;

  const InAppWebViewPage({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Article"),
        backgroundColor: AppColors.getPrimary(context),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri(url),  // Convert Uri to WebUri
        ),
      ),
    );
  }
}
