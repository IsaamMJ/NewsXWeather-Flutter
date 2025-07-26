import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';  // Make sure to import the url_launcher package
import 'package:flutter_inappwebview/flutter_inappwebview.dart';  // Import InAppWebView
import '../../controllers/news_controller.dart';
import '../../../../core/theme/app_colors.dart';

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
          child: Center(child: Text('No news available')),
        );
      }

      // Mood caption
      String moodCaption = '';
      switch (controller.mood.value) {
        case 'cold':
          moodCaption = "It's chilly outside ❄️ — showing stories that match the somber mood.";
          break;
        case 'hot':
          moodCaption = "The weather is heating up 🔥 — here are some intense and alerting headlines.";
          break;
        case 'warm':
          moodCaption = "It's pleasantly warm 🌤 — enjoy these uplifting and cheerful news picks.";
          break;
        default:
          moodCaption = "Here’s your news curated by the weather.";
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

                // Debugging: Check if the URL is being received properly
                print("Article URL: $articleUrl");

                if (articleUrl.isNotEmpty) {
                  // Debugging: Check if the URL can be launched
                  print("Checking if the URL can be launched: $articleUrl");

                  final Uri url = Uri.parse(articleUrl);

                  // Try to launch the URL with url_launcher first
                  if (await canLaunchUrl(url)) {
                    print("Launching URL externally: $articleUrl");
                    await launchUrl(url, mode: LaunchMode.externalApplication); // Opens in external browser
                  } else {
                    print("Cannot launch the URL: $articleUrl");

                    // If URL can't be launched externally, use InAppWebView to open the URL inside the app
                    Get.snackbar(
                      'Error',
                      'Could not open the article externally. Opening inside the app.',
                      snackPosition: SnackPosition.BOTTOM,
                    );

                    // Open URL inside the app using InAppWebView
                    Get.to(() => InAppWebViewPage(url: articleUrl));
                  }
                } else {
                  print("URL is empty");
                  Get.snackbar(
                    'Error',
                    'This article has no URL.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
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
                                ? "No description available"
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
