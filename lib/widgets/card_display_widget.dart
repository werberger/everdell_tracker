import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import '../models/everdell_card.dart';

class CardDisplayWidget extends StatelessWidget {
  final EverdellCard card;
  final bool isSelected;
  final VoidCallback? onTap;
  final double width;
  final double height;
  static Future<double>? _cardAspectRatioFuture;

  const CardDisplayWidget({
    super.key,
    required this.card,
    this.isSelected = false,
    this.onTap,
    this.width = 120,
    this.height = 180,
  });

  Future<double> _getCardAspectRatio() async {
    // Use a single known card image to define the ratio for all cards.
    const referenceImagePath = 'assets/images/cards/architect.webp';
    final data = await rootBundle.load(referenceImagePath);
    final bytes = data.buffer.asUint8List();
    final codec = await ui.instantiateImageCodec(bytes);
    try {
      final frame = await codec.getNextFrame();
      final image = frame.image;
      try {
        final ratio = image.width / image.height;
        return ratio;
      } finally {
        image.dispose();
      }
    } finally {
      codec.dispose();
    }
  }

  Color _getColorForCardColor(CardColor cardColor) {
    switch (cardColor) {
      case CardColor.production:
        return Colors.green.shade700;
      case CardColor.destination:
        return Colors.red.shade700;
      case CardColor.governance:
        return Colors.blue.shade700;
      case CardColor.traveller:
        return Colors.brown.shade400;
      case CardColor.prosperity:
        return Colors.purple.shade700;
    }
  }

  String _getColorName(CardColor cardColor) {
    switch (cardColor) {
      case CardColor.production:
        return 'Production';
      case CardColor.destination:
        return 'Destination';
      case CardColor.governance:
        return 'Governance';
      case CardColor.traveller:
        return 'Traveller';
      case CardColor.prosperity:
        return 'Prosperity';
    }
  }

  @override
  Widget build(BuildContext context) {
    _cardAspectRatioFuture ??= _getCardAspectRatio();

    return GestureDetector(
      onTap: onTap,
      child: FutureBuilder<double>(
        future: _cardAspectRatioFuture,
        builder: (context, snapshot) {
          final aspectRatio = snapshot.data ?? (2.5 / 3.5);

          return AspectRatio(
            aspectRatio: aspectRatio,
            child: Container(
              width: width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.amber : Colors.grey.shade400,
                  width: isSelected ? 4 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: card.hasImage
                    ? Image.asset(
                        card.imagePath,
                        fit: BoxFit.cover, // Matches card ratio, no whitespace
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback to placeholder if image fails to load
                          return _buildPlaceholder(context);
                        },
                      )
                    : _buildPlaceholder(context),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final cardColor = _getColorForCardColor(card.cardColor);

    return Container(
      color: cardColor.withOpacity(0.15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cardColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              card.type == CardType.construction
                  ? Icons.home_work
                  : Icons.pets,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              card.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: cardColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${card.basePoints} VP',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getColorName(card.cardColor),
            style: TextStyle(
              fontSize: 10,
              color: cardColor,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
