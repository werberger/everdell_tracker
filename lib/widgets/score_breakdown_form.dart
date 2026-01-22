import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/app_settings.dart';
import '../models/expansion.dart';

class ScoreBreakdownForm extends StatefulWidget {
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
  final VoidCallback onChanged;

  const ScoreBreakdownForm({
    super.key,
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
    required this.onChanged,
  });

  @override
  State<ScoreBreakdownForm> createState() => _ScoreBreakdownFormState();
}

class _ScoreBreakdownFormState extends State<ScoreBreakdownForm> {
  bool _showTiebreaker = false;

  @override
  Widget build(BuildContext context) {
    final totalResources = _parse(widget.berriesController) +
        _parse(widget.resinController) +
        _parse(widget.pebblesController) +
        _parse(widget.woodController);
    final resourcePoints = totalResources ~/ 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.separatePointTokens)
          _numberField(
            label: 'Point Tokens',
            controller: widget.pointTokensController,
          ),
        // Card points based on entry method
        // When using visual card selection, default to byColor for basic input
        if (widget.cardEntryMethod == CardEntryMethod.simple)
          _numberField(
            label: 'Construction & Critter Points',
            controller: widget.cardPointsController,
          ),
        if (widget.cardEntryMethod == CardEntryMethod.byType) ...[
          _numberField(
            label: 'Construction Points',
            controller: widget.constructionPointsController,
          ),
          _numberField(
            label: 'Critter Points',
            controller: widget.critterPointsController,
          ),
        ],
        if (widget.cardEntryMethod == CardEntryMethod.byColor ||
            widget.cardEntryMethod == CardEntryMethod.visual) ...[
          _numberField(
            label: 'Production (Green)',
            controller: widget.productionPointsController,
          ),
          _numberField(
            label: 'Destination (Red)',
            controller: widget.destinationPointsController,
          ),
          _numberField(
            label: 'Governance (Blue)',
            controller: widget.governancePointsController,
          ),
          _numberField(
            label: 'Traveller (Tan)',
            controller: widget.travellerPointsController,
            allowNegative: true,
          ),
          _numberField(
            label: 'Prosperity (Purple)',
            controller: widget.prosperityCardPointsController,
          ),
        ],
        _numberField(
          label: 'Basic Events (count)',
          controller: widget.basicEventsController,
        ),
        _numberField(
          label: 'Special Events (points)',
          controller: widget.specialEventsController,
        ),
        _numberField(
          label: 'Prosperity Bonus Points',
          controller: widget.prosperityPointsController,
        ),
        _numberField(
          label: 'Journey Points',
          controller: widget.journeyPointsController,
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () {
            setState(() {
              _showTiebreaker = !_showTiebreaker;
            });
          },
          child: Row(
            children: [
              Icon(
                _showTiebreaker ? Icons.expand_more : Icons.chevron_right,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Resources (tiebreaker)',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (!_showTiebreaker && totalResources > 0) ...[
                const SizedBox(width: 8),
                Text(
                  '($totalResources)',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontStyle: FontStyle.italic),
                ),
              ],
            ],
          ),
        ),
        if (_showTiebreaker) ...[
          const SizedBox(height: 8),
          _numberField(
            label: 'Berries',
            controller: widget.berriesController,
          ),
          _numberField(
            label: 'Resin',
            controller: widget.resinController,
          ),
          _numberField(
            label: 'Pebbles',
            controller: widget.pebblesController,
          ),
          _numberField(
            label: 'Wood',
            controller: widget.woodController,
          ),
          if (widget.autoConvertResources)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Resources: $totalResources → $resourcePoints points',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
        const SizedBox(height: 12),
        if (widget.expansions.contains(Expansion.pearlbrook))
          _numberField(
            label: 'Pearlbrook Points',
            controller: widget.pearlPointsController,
          ),
        if (widget.expansions.contains(Expansion.pearlbrook) ||
            widget.expansions.contains(Expansion.mistwood))
          _numberField(
            label: 'Wonder Points',
            controller: widget.wonderPointsController,
          ),
        if (widget.expansions.contains(Expansion.spirecrest))
          _numberField(
            label: 'Weather Points',
            controller: widget.weatherPointsController,
          ),
        if (widget.expansions.contains(Expansion.bellfaire))
          _numberField(
            label: 'Garland Points',
            controller: widget.garlandPointsController,
          ),
        if (widget.expansions.contains(Expansion.mistwood))
          _numberField(
            label: 'Ticket Points',
            controller: widget.ticketPointsController,
          ),
      ],
    );
  }

  Widget _numberField({
    required String label,
    required TextEditingController controller,
    bool allowNegative = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(signed: true),
        inputFormatters: allowNegative
            ? [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*'))]
            : [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: (_) => widget.onChanged(),
      ),
    );
  }

  int _parse(TextEditingController controller) {
    final value = int.tryParse(controller.text);
    return value ?? 0;
  }
}
