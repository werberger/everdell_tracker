import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/expansion.dart';

class ScoreBreakdownForm extends StatelessWidget {
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
  final VoidCallback onChanged;

  const ScoreBreakdownForm({
    super.key,
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
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final totalResources = _parse(berriesController) +
        _parse(resinController) +
        _parse(pebblesController) +
        _parse(woodController);
    final resourcePoints = totalResources ~/ 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (separatePointTokens)
          _numberField(
            label: 'Point Tokens',
            controller: pointTokensController,
          ),
        _numberField(
          label: 'Construction & Critter Points',
          controller: cardPointsController,
        ),
        _numberField(
          label: 'Basic Events (count)',
          controller: basicEventsController,
        ),
        _numberField(
          label: 'Special Events (points)',
          controller: specialEventsController,
        ),
        _numberField(
          label: 'Prosperity Points',
          controller: prosperityPointsController,
        ),
        _numberField(
          label: 'Journey Points',
          controller: journeyPointsController,
        ),
        const SizedBox(height: 12),
        const Text('Resources (tiebreaker)'),
        _numberField(
          label: 'Berries',
          controller: berriesController,
        ),
        _numberField(
          label: 'Resin',
          controller: resinController,
        ),
        _numberField(
          label: 'Pebbles',
          controller: pebblesController,
        ),
        _numberField(
          label: 'Wood',
          controller: woodController,
        ),
        if (autoConvertResources)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Resources: $totalResources → $resourcePoints points',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        const SizedBox(height: 12),
        if (expansions.contains(Expansion.pearlbrook))
          _numberField(
            label: 'Pearlbrook Points',
            controller: pearlPointsController,
          ),
        if (expansions.contains(Expansion.pearlbrook) ||
            expansions.contains(Expansion.mistwood))
          _numberField(
            label: 'Wonder Points',
            controller: wonderPointsController,
          ),
        if (expansions.contains(Expansion.spirecrest))
          _numberField(
            label: 'Weather Points',
            controller: weatherPointsController,
          ),
        if (expansions.contains(Expansion.bellfaire))
          _numberField(
            label: 'Garland Points',
            controller: garlandPointsController,
          ),
        if (expansions.contains(Expansion.mistwood))
          _numberField(
            label: 'Ticket Points',
            controller: ticketPointsController,
          ),
      ],
    );
  }

  Widget _numberField({
    required String label,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: (_) => onChanged(),
      ),
    );
  }

  int _parse(TextEditingController controller) {
    final value = int.tryParse(controller.text);
    return value ?? 0;
  }
}
