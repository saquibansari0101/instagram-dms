import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class DmWebView extends StatefulWidget {
  const DmWebView({super.key});

  @override
  State<DmWebView> createState() => _DmWebViewState();
}

class _DmWebViewState extends State<DmWebView> {
  InAppWebViewController? webViewController;

  final InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllow: "camera; microphone",
    iframeAllowFullscreen: true,
  );

  @override
  Widget build(BuildContext context) {
    // PopScope (replacement for WillPopScope) to handle Android back gesture
    return PopScope(
      canPop: false, // Prevent the default pop navigation
      onPopInvoked: (didPop) async {
        if (didPop) return;

        final controller = webViewController;
        if (controller != null) {
          if (await controller.canGoBack()) {
            controller.goBack();
          } else {
            // We are at the root, do we want to exit?
            // Maybe show a snackbar or just ignore to keep user in app?
            // Since "DM wrapper", likely user wants to stay in.
            // If we want to allow exit on double tap, we can implement that.
            // For now, let's allow pop only if not at root web history?
            // Actually, the user complaint is "back gesture is making app exit" when they probably didn't mean to.
            // So blocking pop is good.
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri("https://www.instagram.com/direct/inbox/"),
            ),
            initialSettings: settings,
            initialUserScripts: UnmodifiableListView<UserScript>([
              UserScript(
                source: """
                    var style = document.createElement('style');
                    style.innerHTML = `
                      /* Hide Navigation Items */
                      a[href="/"] { display: none !important; } /* Home */
                      a[href="/explore/"] { display: none !important; } /* Explore */
                      a[href="/reels/"] { display: none !important; } /* Reels */
                      
                      /* Hide by Aria Label just in case */
                      svg[aria-label="Home"] { display: none !important; }
                      svg[aria-label="Search"] { display: none !important; }
                      svg[aria-label="Explore"] { display: none !important; }
                      svg[aria-label="Reels"] { display: none !important; }
                      
                      /* Hide Header Back Button (usually appearing in mobile web view when deep linked) */
                      /* This button often takes you back to Feed if you are in Inbox */
                      div[role="button"] svg[aria-label="Back"] { display: none !important; }
                      a[href="/"] svg[aria-label="Back"] { display: none !important; }
                      
                      /* Hide "Get App" banner if it appears */
                      div[role="banner"] { display: none !important; }
                    `;
                    document.head.appendChild(style);
                  """,
                injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
              ),
            ]),
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              var uri = navigationAction.request.url!;

              // Allow login pages
              if (uri.path.contains("accounts/login") ||
                  uri.host.contains("facebook.com")) {
                return NavigationActionPolicy.ALLOW;
              }

              // Block explicit navigations to distractions
              if (uri.path == "/" ||
                  uri.path.startsWith("/explore") ||
                  uri.path.startsWith("/reels")) {
                // Redirect back to inbox if they try to go there
                controller.loadUrl(
                  urlRequest: URLRequest(
                    url: WebUri("https://www.instagram.com/direct/inbox/"),
                  ),
                );
                return NavigationActionPolicy.CANCEL;
              }

              return NavigationActionPolicy.ALLOW;
            },
          ),
        ),
      ),
    );
  }
}
