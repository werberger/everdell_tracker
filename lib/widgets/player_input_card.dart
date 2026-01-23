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
  final String entryMethod;
  final ValueChanged<String> onEntryMethodChanged;
  final Map<String, int>? selectedCardCounts;
  final VoidCallback onSelectCards;
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
  final TextEditingController specialEventsCountController;
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
    required this.entryMethod,
    required this.onEntryMethodChanged,
    required this.selectedCardCounts,
    required this.onSelectCards,
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
    required this.specialEventsCountController,
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
              const Text('Player Name', style: TextStyle(fontSize: 12)),
              const SizedBox(height: 4),
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
                      border: OutlineInputBorder(),
                      hintText: 'Enter name',
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Player Order (1st, 2nd, etc.)', style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 4),
                        TextField(
                          controller: widget.playerOrderController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '1-6',
                          ),
                          onChanged: (_) => _updateStartingCards(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Starting Cards', style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 4),
                        TextField(
                          controller: widget.startingCardsController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '5-8',
                          ),
                          onChanged: (_) => widget.onChanged(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Entry Method:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment<String>(
                    value: 'visual',
                    label: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.style, size: 20),
                        SizedBox(height: 4),
                        Text('Card\nSelection', textAlign: TextAlign.center, style: TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                  ButtonSegment<String>(
                    value: 'basic',
                    label: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.list, size: 20),
                        SizedBox(height: 4),
                        Text('Basic\nInput', textAlign: TextAlign.center, style: TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                  ButtonSegment<String>(
                    value: 'quick',
                    label: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.speed, size: 20),
                        SizedBox(height: 4),
                        Text('Quick\nTotal', textAlign: TextAlign.center, style: TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                ],
                selected: {widget.entryMethod},
                onSelectionChanged: (Set<String> selected) {
                  widget.onEntryMethodChanged(selected.first);
                },
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 8, horizontal: 12)),
                ),
              ),
              const SizedBox(height: 8),
              if (widget.entryMethod == 'visual') ...[
                ElevatedButton.icon(
                  onPressed: widget.onSelectCards,
                  icon: const Icon(Icons.grid_view),
                  label: Text(widget.selectedCardCounts != null && widget.selectedCardCounts!.isNotEmpty
                      ? '${widget.selectedCardCounts!.values.fold(0, (sum, count) => sum + count)} cards selected'
                      : 'Select Cards'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Additional Scoring:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (widget.separatePointTokens) ...[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Point Tokens', style: TextStyle(fontSize: 12)),
                            const SizedBox(height: 4),
                            TextField(
                              controller: widget.pointTokensController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: '0',
                              ),
                              onChanged: (_) => widget.onChanged(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Basic Events (count)', style: TextStyle(fontSize: 12)),
                          const SizedBox(height: 4),
                          TextField(
                            controller: widget.basicEventsController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: '0',
                            ),
                            onChanged: (_) => widget.onChanged(),
                          ),
                        ],
                      ),
                    ),
                    if (!widget.separatePointTokens) const Spacer(),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Special Events (count)', style: TextStyle(fontSize: 12)),
                          const SizedBox(height: 4),
                          TextField(
                            controller: widget.specialEventsCountController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: '0',
                            ),
                            onChanged: (_) => widget.onChanged(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Special Events (points)', style: TextStyle(fontSize: 12)),
                          const SizedBox(height: 4),
                          TextField(
                            controller: widget.specialEventsController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: '0',
                            ),
                            onChanged: (_) => widget.onChanged(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Journey Points', style: TextStyle(fontSize: 12)),
                          const SizedBox(height: 4),
                          TextField(
                            controller: widget.journeyPointsController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: '0',
                            ),
                            onChanged: (_) => widget.onChanged(),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Leftover Resources:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Berries', style: TextStyle(fontSize: 12)),
                          const SizedBox(height: 4),
                          TextField(
                            controller: widget.berriesController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: '0',
                            ),
                            onChanged: (_) => widget.onChanged(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Resin', style: TextStyle(fontSize: 12)),
                          const SizedBox(height: 4),
                          TextField(
                            controller: widget.resinController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: '0',
                            ),
                            onChanged: (_) => widget.onChanged(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pebbles', style: TextStyle(fontSize: 12)),
                          const SizedBox(height: 4),
                          TextField(
                            controller: widget.pebblesController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: '0',
                            ),
                            onChanged: (_) => widget.onChanged(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Wood/Twigs', style: TextStyle(fontSize: 12)),
                          const SizedBox(height: 4),
                          TextField(
                            controller: widget.woodController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: '0',
                            ),
                            onChanged: (_) => widget.onChanged(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              if (widget.entryMethod == 'quick')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Score', style: TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: widget.totalController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter total score',
                      ),
                      onChanged: (_) => widget.onChanged(),
                    ),
                  ],
                )
              else if (widget.entryMethod == 'basic')
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
