import 'package:flutter/material.dart';
import 'dart:math' as math;
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

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return const Center(
        child: Text('No cards available'),
      );
    }

    return SizedBox(
      height: 480, // Increased height for better card display
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.cards.length,
        itemBuilder: (context, index) {
          return _buildCard(index);
        },
      ),
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
    
    return AspectRatio(
      aspectRatio: 2.5 / 3.5, // Standard card ratio to prevent cutting
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3 * scale),
              blurRadius: 20 * scale,
              offset: Offset(0, 10 * scale),
            ),
          ],
        ),
      child: Stack(
        children: [
          // Card content
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.green : Colors.grey.shade300,
                width: isSelected ? 4 : 2,
              ),
              color: Colors.white,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Card image or placeholder
                  Expanded(
                    child: card.hasImage
                        ? Image.asset(
                            card.imagePath,
                            fit: BoxFit.cover, // Cover maintains aspect ratio
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholder(card);
                            },
                          )
                        : _buildPlaceholder(card),
                  ),
                  // Card name and points
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: _getColorForType(card.cardColor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          card.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${card.basePoints} VP • ${_getTypeName(card.type)}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Count badge for common cards
          if (cardCount > 0)
            Positioned(
              top: 4,
              right: 4,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.amber,
                child: Text(
                  '$cardCount',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          // Remove button for selected cards
          if (isSelected && widget.onCardRemove != null)
            Positioned(
              bottom: 4,
              left: 4,
              child: IconButton(
                icon: const Icon(Icons.remove_circle),
                color: Colors.red,
                iconSize: 32,
                onPressed: () => widget.onCardRemove!(card),
              ),
            ),
          // Add button for common cards
          if (card.rarity == CardRarity.common && widget.onCardAdd != null)
            Positioned(
              bottom: 4,
              right: 4,
              child: IconButton(
                icon: const Icon(Icons.add_circle),
                color: Colors.green,
                iconSize: 32,
                onPressed: () => widget.onCardAdd!(card),
              ),
            ),
        ],
      ),
    ),
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
        return Colors.purple;
      case CardColor.prosperity:
        return Colors.amber;
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
