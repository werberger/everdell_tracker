import 'package:flutter/material.dart';

import '../models/expansion.dart';

class ExpansionSelector extends StatelessWidget {
  final List<Expansion> selected;
  final ValueChanged<List<Expansion>> onChanged;

  const ExpansionSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: Expansion.values.map((expansion) {
        final isSelected = selected.contains(expansion);
        return FilterChip(
          label: Text(expansion.label),
          selected: isSelected,
          onSelected: (value) {
            final updated = List<Expansion>.from(selected);
            if (value) {
              updated.add(expansion);
            } else {
              updated.remove(expansion);
            }
            onChanged(updated);
          },
        );
      }).toList(),
    );
  }
}
