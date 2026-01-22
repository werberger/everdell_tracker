// Stub for non-web platforms
import 'package:flutter/material.dart';

class PdfViewerWeb extends StatelessWidget {
  final String assetPath;

  const PdfViewerWeb({
    super.key,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    // This should never be called on non-web platforms
    // as kIsWeb check prevents it
    return const Center(
      child: Text('PDF viewer not available on this platform'),
    );
  }
}
