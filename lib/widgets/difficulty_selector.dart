import 'package:flutter/material.dart';

import '../models/difficulty.dart';

class DifficultySelector extends StatelessWidget {
  const DifficultySelector({required this.value, required this.onChanged, super.key});

  final Difficulty value;
  final ValueChanged<Difficulty> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Difficulty>(
      segments: Difficulty.values
          .map(
            (difficulty) => ButtonSegment<Difficulty>(
              value: difficulty,
              label: Text(difficulty.label),
            ),
          )
          .toList(),
      selected: {value},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}