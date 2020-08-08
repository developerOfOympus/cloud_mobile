import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatelessWidget {
  final String url;
  final String name;
  final Completer<WebViewController> _controller = Completer<WebViewController>();

  WebViewPage({@required this.url, @required this.name});

  dispose(){
    this.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name ?? "NA"),
      ),
      body: WebView(
        initialUrl: this.url,
        javascriptMode: JavascriptMode.unrestricted,
        debuggingEnabled: false,
        gestureNavigationEnabled: true,      
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
        },
        initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,        
        javascriptChannels: <JavascriptChannel>[
          _toasterJavascriptChannel(context),
        ].toSet(),
      ),
    );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'Toaster',
      onMessageReceived: (JavascriptMessage message) {
        Scaffold.of(context).showSnackBar(
          SnackBar(content: Text(message.message)),
        );
      }
    );
  }
}
