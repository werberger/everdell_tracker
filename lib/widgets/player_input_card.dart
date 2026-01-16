import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/expansion.dart';
import 'score_breakdown_form.dart';

class PlayerInputCard extends StatelessWidget {
  final int index;
  final TextEditingController nameController;
  final List<String> playerSuggestions;
  final bool isQuickEntry;
  final ValueChanged<bool> onQuickEntryChanged;
  final TextEditingController totalController;
  final bool separatePointTokens;
  final bool autoConvertResources;
  final List<Expansion> expansions;
  final TextEditingController pointTokensController;
  final TextEditingController cardPointsController;
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
    required this.expansions,
    required this.pointTokensController,
    required this.cardPointsController,
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
    required this.onRemove,
    required this.onChanged,
    required this.calculatedTotal,
  });

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
                  child: Text(
                    'Player ${index + 1}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            Autocomplete<String>(
              initialValue: TextEditingValue(text: nameController.text),
              optionsBuilder: (value) {
                if (value.text.trim().isEmpty) {
                  return const Iterable<String>.empty();
                }
                final query = value.text.toLowerCase();
                return playerSuggestions.where(
                  (name) => name.toLowerCase().contains(query),
                );
              },
              onSelected: (value) {
                nameController.text = value;
                onChanged();
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
                    nameController.text = value;
                    onChanged();
                  },
                );
              },
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Quick Total Entry'),
              value: isQuickEntry,
              onChanged: onQuickEntryChanged,
            ),
            const SizedBox(height: 8),
            if (isQuickEntry)
              TextField(
                controller: totalController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Total Score',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => onChanged(),
              )
            else
              ScoreBreakdownForm(
                separatePointTokens: separatePointTokens,
                autoConvertResources: autoConvertResources,
                expansions: expansions,
                pointTokensController: pointTokensController,
                cardPointsController: cardPointsController,
                basicEventsController: basicEventsController,
                specialEventsController: specialEventsController,
                prosperityPointsController: prosperityPointsController,
                journeyPointsController: journeyPointsController,
                berriesController: berriesController,
                resinController: resinController,
                pebblesController: pebblesController,
                woodController: woodController,
                pearlPointsController: pearlPointsController,
                wonderPointsController: wonderPointsController,
                weatherPointsController: weatherPointsController,
                garlandPointsController: garlandPointsController,
                ticketPointsController: ticketPointsController,
                onChanged: onChanged,
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Calculated Total:'),
                const SizedBox(width: 8),
                Text(
                  calculatedTotal?.toString() ?? '—',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
