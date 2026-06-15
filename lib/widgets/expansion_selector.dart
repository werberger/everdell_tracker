import 'package:flutter/material.dart';

import '../models/expansion.dart';

class ExpansionSelector extends StatefulWidget {
  final List<Expansion> selected;
  final ValueChanged<List<Expansion>> onChanged;

  const ExpansionSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<ExpansionSelector> createState() => _ExpansionSelectorState();
}

class _ExpansionSelectorState extends State<ExpansionSelector> {
  bool _expanded = false;

  String _summary() {
    if (widget.selected.isEmpty) {
      return 'Base game only';
    }
    return widget.selected.map((e) => e.label).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  _expanded ? Icons.expand_more : Icons.chevron_right,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _summary(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: Expansion.values.map((expansion) {
              final isSelected = widget.selected.contains(expansion);
              return FilterChip(
                label: Text(expansion.label),
                selected: isSelected,
                onSelected: (value) {
                  final updated = List<Expansion>.from(widget.selected);
                  if (value) {
                    updated.add(expansion);
                  } else {
                    updated.remove(expansion);
                  }
                  widget.onChanged(updated);
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
