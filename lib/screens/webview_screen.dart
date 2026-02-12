import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:webview_windows/webview_windows.dart' as win;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String? _fcmToken;
  String? _deviceId;

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
      if (!_isInitialized) return;
      if (_isWindows) {
        _winController.reload();
      } else {
        _mobileController.reload();
      }
    });
  }

  Future<String> _getDeviceId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor ?? 'unknown_ios';
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.id;
    } else if (Platform.isWindows) {
      var windowsDeviceInfo = await deviceInfo.windowsInfo;
      return windowsDeviceInfo.deviceId;
    }
    return 'unknown_platform';
  }

  Future<void> _initMobileWebview() async {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _mobileController = WebViewController.fromPlatformCreationParams(params);

    try {
      if (Platform.isIOS || Platform.isMacOS) {
        // Auf iOS/macOS kann es einige Sekunden dauern, bis der APNS-Token für FCM bereit ist.
        // Wir warten bis zu 3,5 Sekunden (7 Versuche alle 500ms).
        for (int i = 0; i < 7; i++) {
          String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          if (apnsToken != null) {
            _fcmToken = await FirebaseMessaging.instance.getToken();
            break;
          }
          if (i < 6) {
            debugPrint('Waiting for APNS token (attempt ${i + 1})...');
            await Future.delayed(const Duration(milliseconds: 500));
          }
        }
        if (_fcmToken == null) {
          debugPrint('APNS token still not available after timeout, proceeding without FCM token.');
        }
      } else {
        _fcmToken = await FirebaseMessaging.instance.getToken();
      }
    } catch (e) {
      debugPrint('Error getting FCM token during initialization: $e');
    }
    _deviceId = await _getDeviceId();

    debugPrint('WebView initialization:');
    debugPrint('  FCM Token: $_fcmToken');
    debugPrint('  Device ID: $_deviceId');

    final prefs = await SharedPreferences.getInstance();
    final String? authToken = prefs.getString('auth_token');

    // User-Agent anpassen, damit der Token bei jedem Request dabei ist (auch Sub-Resources)
    String customUserAgent = "TasksSphereMobile; Auth-Token: ${authToken ?? 'none'}; FCM-Token: ${_fcmToken ?? 'none'}; Device-ID: ${_deviceId ?? 'none'}";
    
    // Cookies setzen als Fallback
    final cookieManager = WebViewCookieManager();
    final String domain = Uri.parse(_getInitialUrl()).host;

    if (authToken != null) {
      await cookieManager.setCookie(
        WebViewCookie(name: 'auth_token', value: authToken, domain: domain, path: '/'),
      );
    }

    if (_fcmToken != null) {
      await cookieManager.setCookie(
        WebViewCookie(name: 'fcm_token', value: _fcmToken!, domain: domain, path: '/'),
      );
    }
    await cookieManager.setCookie(
      WebViewCookie(name: 'device_id', value: _deviceId ?? 'unknown', domain: domain, path: '/'),
    );

    _mobileController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(customUserAgent)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel(
        'FlutterLog',
        onMessageReceived: (JavaScriptMessage message) {
          debugPrint('WebView Console: ${message.message}');
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
            // Bei jedem Seitenstart die Bridge injizieren
            _injectLoggingBridge();
            _applySafeAreaFix();
            
            // Log analytics event
            FirebaseAnalytics.instance.logScreenView(
              screenName: 'WebView: $url',
            );
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
            _applySafeAreaFix();
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
            debugPrint('Navigation requested to: ${request.url}');
            // Wir erlauben die Navigation direkt. 
            // Dank User-Agent und Cookies sind die Identifikationsmerkmale bereits enthalten.
            // Ein manuelles loadRequest mit Headers ist hier nicht nötig und würde Reloads verursachen.
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(
        Uri.parse(_getInitialUrl()),
        headers: {
          if (authToken != null) 'Authorization': 'Bearer $authToken',
          if (_fcmToken != null) 'X-FCM-Token': _fcmToken!,
          if (_deviceId != null) 'X-Device-ID': _deviceId!,
        },
      );

    final platform = _mobileController.platform;
    if (platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      platform.setMediaPlaybackRequiresUserGesture(false);
    }
    
    if (!mounted) return;
    setState(() {
      _isInitialized = true;
    });
  }

  void _injectLoggingBridge() {
    const String js = """
      (function() {
        if (window.logIntercepted) return;
        window.logIntercepted = true;
        
        var originalLog = console.log;
        var originalError = console.error;
        var originalWarn = console.warn;
        var originalInfo = console.info;

        console.log = function() {
          FlutterLog.postMessage("LOG: " + Array.from(arguments).join(' '));
          originalLog.apply(console, arguments);
        };
        console.error = function() {
          FlutterLog.postMessage("ERROR: " + Array.from(arguments).join(' '));
          originalError.apply(console, arguments);
        };
        console.warn = function() {
          FlutterLog.postMessage("WARN: " + Array.from(arguments).join(' '));
          originalWarn.apply(console, arguments);
        };
        console.info = function() {
          FlutterLog.postMessage("INFO: " + Array.from(arguments).join(' '));
          originalInfo.apply(console, arguments);
        };
        
        window.onerror = function(message, source, lineno, colno, error) {
          FlutterLog.postMessage("JS ERROR: " + message + " at " + source + ":" + lineno + ":" + colno);
          return false;
        };
        
        console.log("Logging Bridge initialized");
      })();
    """;
    _mobileController.runJavaScript(js);
  }

  void _applySafeAreaFix() {
    const String js = """
      (function() {
        var meta = document.querySelector('meta[name="viewport"]');
        if (meta) {
          if (!meta.content.includes('viewport-fit=cover')) {
            meta.content += ", viewport-fit=cover";
          }
        } else {
          meta = document.createElement('meta');
          meta.name = "viewport";
          meta.content = "width=device-width, initial-scale=1.0, viewport-fit=cover";
          document.head.appendChild(meta);
        }
        
        // Versuche, Padding zu setzen, falls die App es nicht selbst tut
        // Wir nutzen eine kleine Verzögerung, um sicherzugehen, dass das DOM stabil ist
        setTimeout(function() {
          if (window.getComputedStyle(document.body).paddingBottom === '0px') {
            document.body.style.paddingTop = 'env(safe-area-inset-top)';
            document.body.style.paddingBottom = 'env(safe-area-inset-bottom)';
          }
        }, 500);
      })();
    """;
    _mobileController.runJavaScript(js);
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
      backgroundColor: Colors.white,
      body: !_isInitialized
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
    );
  }
}
