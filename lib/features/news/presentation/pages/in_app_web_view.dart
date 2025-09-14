// lib/features/news/presentation/pages/in_app_web_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';

class InAppWebViewPage extends StatefulWidget {
  final String url;
  final String title;

  const InAppWebViewPage({
    Key? key,
    required this.url,
    this.title = "Article"
  }) : super(key: key);

  @override
  State<InAppWebViewPage> createState() => _InAppWebViewPageState();
}

class _InAppWebViewPageState extends State<InAppWebViewPage> {
  bool isLoading = true;
  double loadingProgress = 0;
  String? currentUrl;
  InAppWebViewController? webViewController;
  bool canGoBack = false;
  bool canGoForward = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: AppColors.getPrimary(context),
        elevation: 0,
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              webViewController?.reload();
            },
          ),
          // Share button
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share(
                '${widget.title}\n\n${currentUrl ?? widget.url}',
                subject: widget.title,
              );
            },
          ),
          // Open in external browser
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: () async {
              final uri = Uri.parse(currentUrl ?? widget.url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Progress indicator
              if (isLoading && loadingProgress > 0)
                LinearProgressIndicator(
                  value: loadingProgress,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.getAccent(context),
                  ),
                ),

              // WebView
              Expanded(
                child: InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: WebUri(widget.url),
                  ),
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                  },
                  onLoadStart: (controller, url) {
                    setState(() {
                      isLoading = true;
                      currentUrl = url?.toString();
                    });
                  },
                  onProgressChanged: (controller, progress) {
                    setState(() {
                      loadingProgress = progress / 100.0;
                    });
                  },
                  onLoadStop: (controller, url) async {
                    setState(() {
                      isLoading = false;
                      currentUrl = url?.toString();
                    });

                    // Update navigation buttons
                    canGoBack = await controller.canGoBack();
                    canGoForward = await controller.canGoForward();
                    setState(() {});
                  },
                  onLoadError: (controller, url, code, message) {
                    setState(() {
                      isLoading = false;
                    });

                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to load article: $message'),
                        backgroundColor: Colors.red,
                        action: SnackBarAction(
                          label: 'Retry',
                          textColor: Colors.white,
                          onPressed: () {
                            controller.reload();
                          },
                        ),
                      ),
                    );
                  },
                  initialSettings: InAppWebViewSettings(
                    // Basic settings
                    javaScriptEnabled: true,
                    domStorageEnabled: true,

                    // Performance optimizations
                    cacheEnabled: true,
                    clearCache: false,

                    // User experience
                    supportZoom: true,
                    builtInZoomControls: false,
                    displayZoomControls: false,

                    // Mobile optimizations
                    useWideViewPort: true,
                    loadWithOverviewMode: true,

                    // Media settings
                    mediaPlaybackRequiresUserGesture: false,
                    allowsInlineMediaPlayback: true,

                    // Security - REMOVED problematic allowingReadAccessTo
                    allowsLinkPreview: true,

                    // Scrolling
                    verticalScrollBarEnabled: true,
                    horizontalScrollBarEnabled: true,

                    // Other useful settings
                    useShouldOverrideUrlLoading: false,
                    transparentBackground: false,
                  ),
                  onReceivedHttpError: (controller, request, errorResponse) {
                    print('HTTP Error: ${errorResponse.statusCode}');
                  },
                  shouldOverrideUrlLoading: (controller, navigationAction) async {
                    final uri = navigationAction.request.url;

                    // Handle special URL schemes
                    if (uri != null) {
                      final url = uri.toString();
                      if (url.startsWith('mailto:') ||
                          url.startsWith('tel:') ||
                          url.startsWith('sms:')) {
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                          return NavigationActionPolicy.CANCEL;
                        }
                      }
                    }

                    return NavigationActionPolicy.ALLOW;
                  },
                ),
              ),
            ],
          ),

          // Full-screen loading indicator
          if (isLoading && loadingProgress == 0)
            Container(
              color: AppColors.getBackground(context),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.getAccent(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading article...',
                      style: TextStyle(
                        color: AppColors.getTextSecondary(context),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please wait',
                      style: TextStyle(
                        color: AppColors.getTextSecondary(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),

      // Bottom navigation bar for web controls
      bottomNavigationBar: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.getCardColor(context),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Back button
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: canGoBack
                    ? AppColors.getTextPrimary(context)
                    : AppColors.getTextSecondary(context).withOpacity(0.3),
              ),
              onPressed: canGoBack ? () {
                webViewController?.goBack();
              } : null,
            ),

            // Forward button
            IconButton(
              icon: Icon(
                Icons.arrow_forward,
                color: canGoForward
                    ? AppColors.getTextPrimary(context)
                    : AppColors.getTextSecondary(context).withOpacity(0.3),
              ),
              onPressed: canGoForward ? () {
                webViewController?.goForward();
              } : null,
            ),

            // Reload button
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: AppColors.getTextPrimary(context),
              ),
              onPressed: () {
                webViewController?.reload();
              },
            ),

            // Share button
            IconButton(
              icon: Icon(
                Icons.share,
                color: AppColors.getTextPrimary(context),
              ),
              onPressed: () {
                Share.share(
                  '${widget.title}\n\n${currentUrl ?? widget.url}',
                  subject: widget.title,
                );
              },
            ),

            // Open in browser button
            IconButton(
              icon: Icon(
                Icons.open_in_browser,
                color: AppColors.getTextPrimary(context),
              ),
              onPressed: () async {
                final uri = Uri.parse(currentUrl ?? widget.url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}