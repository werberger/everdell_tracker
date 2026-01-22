// Web-specific PDF viewer using iframe
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class PdfViewerWeb extends StatefulWidget {
  final String assetPath;

  const PdfViewerWeb({
    super.key,
    required this.assetPath,
  });

  @override
  State<PdfViewerWeb> createState() => _PdfViewerWebState();
}

class _PdfViewerWebState extends State<PdfViewerWeb> {
  static int _iframeCounter = 0;
  late final String _iframeId;

  @override
  void initState() {
    super.initState();
    _iframeId = 'pdf-iframe-${_iframeCounter++}';
    _registerIframe();
  }

  void _registerIframe() {
    // Convert asset path to web-accessible URL
    // Assets are served from the root, so 'assets/images/file.pdf' becomes '/assets/images/file.pdf'
    final pdfUrl = widget.assetPath.startsWith('/') 
        ? widget.assetPath 
        : '/${widget.assetPath}';
    
    // Create iframe element
    final iframe = html.IFrameElement()
      ..src = pdfUrl
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%';

    // Register the platform view
    ui.platformViewRegistry.registerViewFactory(
      _iframeId,
      (int viewId) => iframe,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: HtmlElementView(viewType: _iframeId),
    );
  }
}
