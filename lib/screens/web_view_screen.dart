import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewScreenArguments {
  final String? url;
  final String title;

  WebViewScreenArguments(this.url, this.title);
}

class WebViewScreen extends StatefulWidget {
  static const routeName = '/web-view-screen';
  const WebViewScreen({Key? key}) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {

  double _progress = 0;
  late InAppWebViewController webView;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as WebViewScreenArguments;
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(args.title),
      ),
      body: Stack(
        children: [
          InAppWebView(
              initialUrlRequest:
                  URLRequest(url: Uri.parse(args.url!)),
              onWebViewCreated: (InAppWebViewController controller) {
                webView = controller;
              },
              onProgressChanged:
                  (InAppWebViewController controller, int progress) {
                setState(() {
                  _progress = progress / 100;
                });
              }),
          _progress < 1.0 ? LinearProgressIndicator(value: _progress) : Container()
        ],
      ),
    );
  }
}
