import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_page.dart';

class DmWebView extends StatefulWidget {
  const DmWebView({super.key});

  @override
  State<DmWebView> createState() => _DmWebViewState();
}

class _DmWebViewState extends State<DmWebView> {
  InAppWebViewController? webViewController;
  late final InAppWebViewSettings settings;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Settings State
  bool _hideHome = true;
  bool _hideExplore = true;
  bool _hideReels = true;

  // Loading & Error state
  bool _isLoading = true;
  bool _isError = false;
  String _errorDescription = "";

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _initSettings();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    // Simple iOS init - we might need more config for foreground logic if desired
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
          macOS: initializationSettingsDarwin,
        );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Request permissions (Android 13+)
    final platform = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await platform?.requestNotificationsPermission();
  }

  Future<void> _showNotification(int count) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'dm_channel',
          'Direct Messages',
          channelDescription: 'Notifications for incoming Instagram DMs',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'New Message',
          color: Colors.purple,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'New Messages',
      'You have $count unread message${count > 1 ? "s" : ""}',
      notificationDetails,
    );
  }

  Future<void> _initSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hideHome = prefs.getBool('hide_home') ?? true;
      _hideExplore = prefs.getBool('hide_explore') ?? true;
      _hideReels = prefs.getBool('hide_reels') ?? true;
      _isLoading = false;
    });

    settings = InAppWebViewSettings(
      isInspectable: kDebugMode,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      iframeAllow: "camera; microphone",
      iframeAllowFullscreen: true,
      cacheEnabled: true,
      domStorageEnabled: true,
      databaseEnabled: true,
      preferredContentMode: UserPreferredContentMode.MOBILE,
    );
  }

  String _generateUserScript() {
    String css = """
      /* Base generic hiding */
      /* Hide Header Back Button */
      div[role="button"] svg[aria-label="Back"] { display: none !important; }
      a[href="/"] svg[aria-label="Back"] { display: none !important; }
      /* Hide Banner */
      div[role="banner"] { display: none !important; }
      /* Ensure full height */
      html, body { height: 100%; overscroll-behavior: none; }
    """;

    String mutationLogic = "";

    if (_hideHome) {
      css += """
        a[href="/"] { display: none !important; }
        svg[aria-label="Home"] { display: none !important; }
      """;
      mutationLogic += """
        document.querySelectorAll('a[href="/"]').forEach(el => el.style.display = 'none');
        document.querySelectorAll('svg[aria-label="Home"]').forEach(el => {
            let ptr = el.closest('a');
            if(ptr) ptr.style.display = 'none';
            else el.style.display = 'none';
        });
      """;
    }

    if (_hideExplore) {
      css += """
        a[href="/explore/"] { display: none !important; }
        svg[aria-label="Search"] { display: none !important; }
        svg[aria-label="Explore"] { display: none !important; }
      """;
      mutationLogic += """
        document.querySelectorAll('a[href*="/explore/"]').forEach(el => el.style.display = 'none');
      """;
    }

    if (_hideReels) {
      css += """
        a[href="/reels/"] { display: none !important; }
        svg[aria-label="Reels"] { display: none !important; }
      """;
      mutationLogic += """
        document.querySelectorAll('a[href*="/reels/"]').forEach(el => el.style.display = 'none');
      """;
    }

    mutationLogic += """
      document.querySelectorAll('svg[aria-label="Back"]').forEach(el => el.style.display = 'none');
    """;

    return """
      var style = document.createElement('style');
      style.innerHTML = `$css`;
      document.head.appendChild(style);

      const observer = new MutationObserver((mutations) => {
        $mutationLogic
      });
      observer.observe(document.body, { childList: true, subtree: true });
      
      // --- NOTIFICATION LOGIC ---
      // Observe title changes for "(N) Instagram"
      let lastCount = 0;
      const titleObserver = new MutationObserver(() => {
         const title = document.title;
         const regex = /^\\((\\d+)\\)/; 
         const match = title.match(regex);
         if (match) {
            const count = parseInt(match[1]);
            if (count > lastCount) {
               // New message
               window.flutter_inappwebview.callHandler('onNotify', count);
            }
            lastCount = count;
         } else {
            lastCount = 0;
         }
      });
      titleObserver.observe(document.querySelector('title'), { childList: true });
    """;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Build the main WebView content
    Widget content;

    if (_isError) {
      content = Container(
        color: Colors.black,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  "Something went wrong",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorDescription.isNotEmpty
                      ? _errorDescription
                      : "Please check your internet connection.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isError = false;
                      _errorDescription = "";
                    });
                    webViewController?.reload();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text("Retry"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      content = InAppWebView(
        key: ValueKey("$_hideHome$_hideExplore$_hideReels"),
        initialUrlRequest: URLRequest(
          url: WebUri("https://www.instagram.com/direct/inbox/"),
        ),
        initialSettings: settings,
        initialUserScripts: UnmodifiableListView<UserScript>([
          UserScript(
            source: _generateUserScript(),
            injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
          ),
        ]),
        onWebViewCreated: (controller) {
          webViewController = controller;

          // Register Handler
          controller.addJavaScriptHandler(
            handlerName: 'onNotify',
            callback: (args) {
              if (args.isNotEmpty) {
                final int count = args[0] as int;
                // Trigger notification
                _showNotification(count);
              }
            },
          );
        },
        onReceivedError: (controller, request, error) {
          if (request.isForMainFrame ?? false) {
            setState(() {
              _isError = true;
              _errorDescription = error.description;
            });
          }
        },
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          var uri = navigationAction.request.url!;

          // Allow auth
          if (uri.path.contains("accounts/login") ||
              uri.host.contains("facebook.com")) {
            return NavigationActionPolicy.ALLOW;
          }

          // Conditional Blocking
          if (_hideHome && uri.path == "/") {
            controller.loadUrl(
              urlRequest: URLRequest(
                url: WebUri("https://www.instagram.com/direct/inbox/"),
              ),
            );
            return NavigationActionPolicy.CANCEL;
          }

          if (_hideExplore && uri.path.startsWith("/explore")) {
            controller.loadUrl(
              urlRequest: URLRequest(
                url: WebUri("https://www.instagram.com/direct/inbox/"),
              ),
            );
            return NavigationActionPolicy.CANCEL;
          }

          if (_hideReels && uri.path.startsWith("/reels")) {
            controller.loadUrl(
              urlRequest: URLRequest(
                url: WebUri("https://www.instagram.com/direct/inbox/"),
              ),
            );
            return NavigationActionPolicy.CANCEL;
          }

          return NavigationActionPolicy.ALLOW;
        },
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final controller = webViewController;
        if (controller != null) {
          if (await controller.canGoBack()) {
            controller.goBack();
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        floatingActionButton: _isError
            ? null
            : FloatingActionButton(
                mini: true,
                backgroundColor: Colors.grey[900]?.withOpacity(0.5),
                child: const Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                  await _initSettings();
                  webViewController?.reload();
                },
              ),
        body: SafeArea(child: content),
      ),
    );
  }
}
