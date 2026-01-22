import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import '../models/everdell_card.dart';

/// A carousel widget that displays cards in a fan/stack effect
/// with smooth scrolling and visual depth
class CardCarouselWidget extends StatefulWidget {
  final List<EverdellCard> cards;
  final Function(EverdellCard) onCardTap;
  final Function(EverdellCard)? onCardAdd;
  final Function(EverdellCard)? onCardRemove;
  final Set<String> selectedCardIds;
  final Map<String, int> selectedCardCounts;

  const CardCarouselWidget({
    super.key,
    required this.cards,
    required this.onCardTap,
    this.onCardAdd,
    this.onCardRemove,
    required this.selectedCardIds,
    required this.selectedCardCounts,
  });

  @override
  State<CardCarouselWidget> createState() => _CardCarouselWidgetState();
}

class _CardCarouselWidgetState extends State<CardCarouselWidget> {
  late PageController _pageController;
  double _currentPage = 0;
  static Future<double>? _cardAspectRatioFuture;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.5, // Show half of each adjacent card for overlap
      initialPage: 0,
    );
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return const Center(
        child: Text('No cards available'),
      );
    }

    // Use all available space
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.cards.length,
      itemBuilder: (context, index) {
        return _buildCard(index);
      },
    );
  }

  Widget _buildCard(int index) {
    final card = widget.cards[index];
    final isSelected = widget.selectedCardIds.contains(card.id);

    // Calculate how far this card is from the center
    final difference = (index - _currentPage).abs();
    
    // Scale: center card is largest, others scale down more gently
    final scale = 1.0 - (difference * 0.15).clamp(0.0, 0.4);
    
    // Rotation: fan effect - cards on sides rotate slightly
    final rotation = (index - _currentPage) * 0.1;
    
    // Vertical offset: create arc/fan effect
    final verticalOffset = (difference * 40).clamp(0.0, 80.0);
    
    // Z-index effect: cards further from center are "behind"
    final zOffset = -difference * 50;

    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // Perspective
            ..translate(0.0, 0.0, zOffset) // Push back cards for depth
            ..rotateZ(rotation) // Rotate for fan effect
            ..scale(scale),
          child: Container(
            margin: EdgeInsets.only(
              top: verticalOffset,
              bottom: 20,
            ),
            child: GestureDetector(
              onTap: () {
                // If not center card, scroll to it first
                if ((index - _currentPage).abs() > 0.5) {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  // If center card, select it
                  widget.onCardTap(card);
                }
              },
              child: _buildCardContent(card, isSelected, scale),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardContent(EverdellCard card, bool isSelected, double scale) {
    final cardCount = widget.selectedCardCounts[card.id] ?? 0;

    _cardAspectRatioFuture ??= _getCardAspectRatio();

    return FutureBuilder<double>(
      future: _cardAspectRatioFuture,
      builder: (context, snapshot) {
        final aspectRatio = snapshot.data ?? (2.5 / 3.5);

        return AspectRatio(
          aspectRatio: aspectRatio,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Show text overlay only when card is small (< 140px wide)
              final showTextOverlay = constraints.maxWidth < 140;
              
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.green : Colors.grey.shade300,
                    width: isSelected ? 4 : 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3 * scale),
                      blurRadius: 20 * scale,
                      offset: Offset(0, 10 * scale),
                    ),
                  ],
                  color: Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Card image fills entire space
                      if (card.hasImage)
                        Image.asset(
                          card.imagePath,
                          fit: BoxFit.cover, // Matches card ratio, no whitespace
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholder(card);
                          },
                        )
                      else
                        _buildPlaceholder(card),
                      
                      // Text overlay at bottom (only when card is small)
                      if (showTextOverlay)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getColorForType(card.cardColor).withOpacity(0.95),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  card.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${card.basePoints} VP • ${_getTypeName(card.type)}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      
                      // Top button row
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.5),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Remove button (left)
                              if (isSelected && widget.onCardRemove != null)
                                IconButton(
                                  icon: const Icon(Icons.remove_circle),
                                  color: Colors.red,
                                  iconSize: 30,
                                  onPressed: () => widget.onCardRemove!(card),
                                )
                              else
                                const SizedBox(width: 48),
                              
                              // Count badge (center)
                              if (cardCount > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$cardCount',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              else
                                const SizedBox(width: 48),
                              
                              // Add button (right)
                              if (card.rarity == CardRarity.common && widget.onCardAdd != null)
                                IconButton(
                                  icon: const Icon(Icons.add_circle),
                                  color: Colors.green,
                                  iconSize: 30,
                                  onPressed: () => widget.onCardAdd!(card),
                                )
                              else
                                const SizedBox(width: 48),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder(EverdellCard card) {
    return Container(
      color: _getColorForType(card.cardColor).withOpacity(0.2),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getIconForType(card.type),
                size: 48,
                color: _getColorForType(card.cardColor),
              ),
              const SizedBox(height: 8),
              Text(
                card.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _getColorForType(card.cardColor),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorForType(CardColor color) {
    switch (color) {
      case CardColor.production:
        return Colors.green;
      case CardColor.governance:
        return Colors.blue;
      case CardColor.destination:
        return Colors.red;
      case CardColor.traveller:
        return Colors.amber; // Tan/Yellow
      case CardColor.prosperity:
        return Colors.purple;
    }
  }

  IconData _getIconForType(CardType type) {
    switch (type) {
      case CardType.construction:
        return Icons.home;
      case CardType.critter:
        return Icons.pets;
    }
  }

  String _getTypeName(CardType type) {
    switch (type) {
      case CardType.construction:
        return 'Construction';
      case CardType.critter:
        return 'Critter';
    }
  }
}
