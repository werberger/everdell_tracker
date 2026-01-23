// Web-specific PDF viewer - opens PDF in new window
import 'dart:html' as html;
import 'package:flutter/material.dart';

class PdfViewerWeb extends StatelessWidget {
  final String assetPath;

  const PdfViewerWeb({
    super.key,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    // Convert asset path to web-accessible URL
    // Assets are served from the root, so 'assets/images/file.pdf' becomes '/assets/images/file.pdf'
    final pdfUrl = assetPath.startsWith('/') 
        ? assetPath 
        : '/$assetPath';
    
    // Open PDF in new window/tab
    html.window.open(pdfUrl, '_blank');
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.picture_as_pdf,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Opening PDF in new window...',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'If the PDF didn\'t open, click the button below',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => html.window.open(pdfUrl, '_blank'),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open PDF'),
          ),
        ],
      ),
    );
  }
}
