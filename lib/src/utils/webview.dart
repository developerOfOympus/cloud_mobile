import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class WebView extends StatelessWidget {

  final String url;
  final String name;

  WebView({@required this.url, @required this.name});

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: this.url,
      withLocalStorage: true,
      hidden: true,
      withZoom: true,
      displayZoomControls: true,
      debuggingEnabled: false,            
      appBar: AppBar(title: Text(this.name ?? "NA"),),      
      initialChild: Container(
        color: Colors.redAccent,
        child: const Center(
          child: CircularProgressIndicator()
        ),
      ),
    );
  }
}