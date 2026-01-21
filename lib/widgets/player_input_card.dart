import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/app_settings.dart';
import '../models/expansion.dart';
import 'score_breakdown_form.dart';

class PlayerInputCard extends StatefulWidget {
  final int index;
  final TextEditingController nameController;
  final List<String> playerSuggestions;
  final bool isQuickEntry;
  final ValueChanged<bool> onQuickEntryChanged;
  final TextEditingController totalController;
  final bool separatePointTokens;
  final bool autoConvertResources;
  final CardEntryMethod cardEntryMethod;
  final List<Expansion> expansions;
  final TextEditingController pointTokensController;
  final TextEditingController cardPointsController;
  final TextEditingController constructionPointsController;
  final TextEditingController critterPointsController;
  final TextEditingController productionPointsController;
  final TextEditingController destinationPointsController;
  final TextEditingController governancePointsController;
  final TextEditingController travellerPointsController;
  final TextEditingController prosperityCardPointsController;
  final TextEditingController basicEventsController;
  final TextEditingController specialEventsController;
  final TextEditingController prosperityPointsController;
  final TextEditingController journeyPointsController;
  final TextEditingController berriesController;
  final TextEditingController resinController;
  final TextEditingController pebblesController;
  final TextEditingController woodController;
  final TextEditingController pearlPointsController;
  final TextEditingController wonderPointsController;
  final TextEditingController weatherPointsController;
  final TextEditingController garlandPointsController;
  final TextEditingController ticketPointsController;
  final TextEditingController playerOrderController;
  final TextEditingController startingCardsController;
  final VoidCallback onRemove;
  final VoidCallback onChanged;
  final int? calculatedTotal;

  const PlayerInputCard({
    super.key,
    required this.index,
    required this.nameController,
    required this.playerSuggestions,
    required this.isQuickEntry,
    required this.onQuickEntryChanged,
    required this.totalController,
    required this.separatePointTokens,
    required this.autoConvertResources,
    required this.cardEntryMethod,
    required this.expansions,
    required this.pointTokensController,
    required this.cardPointsController,
    required this.constructionPointsController,
    required this.critterPointsController,
    required this.productionPointsController,
    required this.destinationPointsController,
    required this.governancePointsController,
    required this.travellerPointsController,
    required this.prosperityCardPointsController,
    required this.basicEventsController,
    required this.specialEventsController,
    required this.prosperityPointsController,
    required this.journeyPointsController,
    required this.berriesController,
    required this.resinController,
    required this.pebblesController,
    required this.woodController,
    required this.pearlPointsController,
    required this.wonderPointsController,
    required this.weatherPointsController,
    required this.garlandPointsController,
    required this.ticketPointsController,
    required this.playerOrderController,
    required this.startingCardsController,
    required this.onRemove,
    required this.onChanged,
    required this.calculatedTotal,
  });

  @override
  State<PlayerInputCard> createState() => _PlayerInputCardState();
}

class _PlayerInputCardState extends State<PlayerInputCard> {
  bool _isExpanded = true;

  void _updateStartingCards() {
    final order = int.tryParse(widget.playerOrderController.text);
    if (order != null && order >= 1) {
      final cards = _calculateStartingCards(order);
      widget.startingCardsController.text = cards.toString();
      widget.onChanged();
    }
  }

  int _calculateStartingCards(int playerOrder) {
    if (playerOrder == 1) return 5;
    if (playerOrder == 2) return 6;
    if (playerOrder == 3) return 7;
    return 8;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Row(
                      children: [
                        Icon(
                          _isExpanded
                              ? Icons.expand_more
                              : Icons.chevron_right,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Player ${widget.index + 1}${widget.nameController.text.isEmpty ? '' : ' - ${widget.nameController.text}'}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (!_isExpanded && widget.calculatedTotal != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '(${widget.calculatedTotal})',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            if (_isExpanded) ...[
              const SizedBox(height: 8),
              Autocomplete<String>(
                initialValue:
                    TextEditingValue(text: widget.nameController.text),
                optionsBuilder: (value) {
                  if (value.text.trim().isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  final query = value.text.toLowerCase();
                  return widget.playerSuggestions.where(
                    (name) => name.toLowerCase().contains(query),
                  );
                },
                onSelected: (value) {
                  widget.nameController.text = value;
                  widget.onChanged();
                },
                fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Player Name',
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                    onChanged: (value) {
                      widget.nameController.text = value;
                      widget.onChanged();
                      setState(() {}); // Refresh to show name in collapsed header
                    },
                  );
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widget.playerOrderController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Player Order (1st, 2nd, etc.)',
                        border: OutlineInputBorder(),
                        hintText: '1-6',
                      ),
                      onChanged: (_) => _updateStartingCards(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: widget.startingCardsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Starting Cards',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => widget.onChanged(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Quick Total Entry'),
                value: widget.isQuickEntry,
                onChanged: widget.onQuickEntryChanged,
              ),
              const SizedBox(height: 8),
              if (widget.isQuickEntry)
                TextField(
                  controller: widget.totalController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Total Score',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => widget.onChanged(),
                )
              else
                ScoreBreakdownForm(
                  separatePointTokens: widget.separatePointTokens,
                  autoConvertResources: widget.autoConvertResources,
                  cardEntryMethod: widget.cardEntryMethod,
                  expansions: widget.expansions,
                  pointTokensController: widget.pointTokensController,
                  cardPointsController: widget.cardPointsController,
                  constructionPointsController:
                      widget.constructionPointsController,
                  critterPointsController: widget.critterPointsController,
                  productionPointsController: widget.productionPointsController,
                  destinationPointsController:
                      widget.destinationPointsController,
                  governancePointsController: widget.governancePointsController,
                  travellerPointsController: widget.travellerPointsController,
                  prosperityCardPointsController:
                      widget.prosperityCardPointsController,
                  basicEventsController: widget.basicEventsController,
                  specialEventsController: widget.specialEventsController,
                  prosperityPointsController:
                      widget.prosperityPointsController,
                  journeyPointsController: widget.journeyPointsController,
                  berriesController: widget.berriesController,
                  resinController: widget.resinController,
                  pebblesController: widget.pebblesController,
                  woodController: widget.woodController,
                  pearlPointsController: widget.pearlPointsController,
                  wonderPointsController: widget.wonderPointsController,
                  weatherPointsController: widget.weatherPointsController,
                  garlandPointsController: widget.garlandPointsController,
                  ticketPointsController: widget.ticketPointsController,
                  onChanged: widget.onChanged,
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Calculated Total:'),
                  const SizedBox(width: 8),
                  Text(
                    widget.calculatedTotal?.toString() ?? '—',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
