import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SignInWebView extends ConsumerStatefulWidget {
  const SignInWebView({
    super.key,
    required this.initialUrl,
    required this.redirectTo,
  });

  final String initialUrl;
  final String redirectTo;

  @override
  ConsumerState<SignInWebView> createState() => SignInWebViewState();
}

class SignInWebViewState extends ConsumerState<SignInWebView> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: kDebugMode, // Allows inspection when in debug mode
    mediaPlaybackRequiresUserGesture:
        false, // Media playback doesn't require user interaction
    allowsInlineMediaPlayback:
        false, // Prevents inline media playback (e.g., videos won't autoplay)
    iframeAllow:
        "camera; microphone", // Enables access to the camera and microphone for iframes
    iframeAllowFullscreen: true, // Allows iframes to go fullscreen
    userAgent: 'mobile_random', // Custom user agent string for the webview
  );

  PullToRefreshController? pullToRefreshController;
  String url = "";
  double progress = 0;

  @override
  void initState() {
    super.initState();

    // Initializing the pull-to-refresh controller, which is only available on mobile platforms
    pullToRefreshController = kIsWeb
        ? null // On web platforms, pull-to-refresh isn't available, so set to null
        : PullToRefreshController(
            settings: PullToRefreshSettings(
              color: Colors.purple, // Color for the pull-to-refresh indicator
            ),
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController
                    ?.reload(); // Reloads the page on Android when pulled to refresh
              } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                // On iOS, instead of reloading, it fetches the current URL and loads it again
                webViewController?.loadUrl(
                    urlRequest:
                        URLRequest(url: await webViewController?.getUrl()));
              }
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  key: webViewKey,
                  initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
                  initialSettings:
                      settings, // Applies the webview settings defined earlier
                  pullToRefreshController:
                      pullToRefreshController, // Attach the pull-to-refresh controller
                  onWebViewCreated: (controller) {
                    webViewController =
                        controller; // Stores the webview controller for later use
                  },
                  onPermissionRequest: (controller, request) async {
                    // Automatically grants permissions requested by the webview (e.g., camera access)
                    return PermissionResponse(
                      resources: request.resources,
                      action: PermissionResponseAction.GRANT,
                    );
                  },
                  onLoadStop: (controller, url) async {
                    pullToRefreshController
                        ?.endRefreshing(); // Stops the pull-to-refresh animation
                    controller.addJavaScriptHandler(
                      handlerName: 'mobileSessionHandler',
                      callback: (args) async {
                        // JavaScript handler that gets triggered from the webview
                        final goRouter = GoRouter.of(context);
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('session',
                            args[0]['session']); // Save the session data
                        await prefs.setString('session',
                            args[0]['sessionToken']); // Save the session token
                        if (mounted) {
                          goRouter.pushReplacement(widget
                              .redirectTo); // Navigate to the specified redirect URL
                        }
                      },
                    );
                  },
                  onReceivedError: (controller, request, error) {
                    pullToRefreshController
                        ?.endRefreshing(); // Stops pull-to-refresh even if an error occurs
                  },
                  onProgressChanged: (controller, progress) {
                    if (progress == 100) {
                      pullToRefreshController
                          ?.endRefreshing(); // Stops the pull-to-refresh once loading is complete
                    }
                    setState(() {
                      this.progress = progress /
                          100; // Updates the progress value for the progress indicator
                    });
                  },
                ),
                // Displays a loading indicator when the page is still loading
                progress < 1.0
                    ? LinearProgressIndicator(value: progress)
                    : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
