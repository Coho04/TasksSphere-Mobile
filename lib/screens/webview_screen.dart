import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:webview_windows/webview_windows.dart' as win;
import '../services/push_notification_service.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  // Controller für mobile (Android/iOS)
  late final WebViewController _mobileController;
  
  // Controller für Windows
  final _winController = win.WebviewController();
  
  bool _isWindows = false;
  bool _isInitialized = false;
  StreamSubscription? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _isWindows = Platform.isWindows;
    
    if (_isWindows) {
      _initWindowsWebview();
    } else {
      _initMobileWebview();
    }

    _notificationSubscription = PushNotificationService.onMessageStream.listen((message) {
      debugPrint('WebViewScreen: Received notification, reloading webview...');
      if (_isWindows) {
        _winController.reload();
      } else {
        _mobileController.reload();
      }
    });
  }

  void _initMobileWebview() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _mobileController = WebViewController.fromPlatformCreationParams(params);

    _mobileController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
            if (Platform.isAndroid) {
              _fixLocalhostUrls();
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
  url: ${error.url}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(_getInitialUrl()));

    final platform = _mobileController.platform;
    if (platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      platform.setMediaPlaybackRequiresUserGesture(false);
    }
    
    setState(() {
      _isInitialized = true;
    });
  }

  void _fixLocalhostUrls() {
    // JavaScript-Hack, um localhost-URLs durch 10.0.2.2 zu ersetzen
    const String js = """
      (function() {
        var elements = document.querySelectorAll('link[href*="localhost"], script[src*="localhost"], img[src*="localhost"], a[href*="localhost"]');
        var fixedCount = 0;
        elements.forEach(function(el) {
          var oldUrl = el.tagName === 'LINK' ? el.href : el.src;
          if (!oldUrl && el.tagName === 'A') oldUrl = el.href;
          
          if (oldUrl && oldUrl.indexOf('localhost') !== -1) {
            var newUrl = oldUrl.replace('localhost', '10.0.2.2');
            if (el.tagName === 'LINK' && el.rel === 'stylesheet') {
              var newLink = document.createElement('link');
              newLink.rel = 'stylesheet';
              newLink.href = newUrl;
              document.head.appendChild(newLink);
              el.remove();
            } else if (el.tagName === 'SCRIPT') {
              var newScript = document.createElement('script');
              newScript.src = newUrl;
              newScript.type = el.type || 'text/javascript';
              document.body.appendChild(newScript);
              el.remove();
            } else if (el.href) {
              el.href = newUrl;
            } else if (el.src) {
              el.src = newUrl;
            }
            fixedCount++;
          }
        });
        console.log('Fixed ' + fixedCount + ' localhost URLs');
      })();
    """;
    _mobileController.runJavaScript(js);
  }

  Future<void> _initWindowsWebview() async {
    try {
      await _winController.initialize();
      await _winController.setPopupWindowPolicy(win.WebviewPopupWindowPolicy.deny);
      await _winController.loadUrl(_getInitialUrl());
      
      if (!mounted) return;
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Windows WebView error: $e');
    }
  }

  String _getInitialUrl() {
    return 'https://tasks.code-sphere.de';
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    if (_isWindows) {
      _winController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: !_isInitialized
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('images/taskssphere_only_logo.png', height: 100),
                    const SizedBox(height: 24),
                    const CircularProgressIndicator(),
                  ],
                ),
              )
            : _isWindows
                ? win.Webview(_winController)
                : WebViewWidget(controller: _mobileController),
      ),
    );
  }
}
