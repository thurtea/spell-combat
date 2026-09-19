import 'package:flutter/material.dart';

import '../models/letter_tile.dart';

/// A single draggable-feeling letter tile in the player's hand.
class LetterTileWidget extends StatelessWidget {
  const LetterTileWidget({
    required this.tile,
    required this.onTap,
    this.onLongPress,
    super.key,
  });

  final LetterTile tile;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        onLongPress: onLongPress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: 52,
          height: 60,
          transform: tile.isSelected
              ? (Matrix4.identity()..translateByDouble(0.0, -8.0, 0.0, 1.0))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color: tile.isSelected ? colors.secondary : colors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: tile.isSelected ? colors.secondary : colors.outlineVariant,
              width: tile.isSelected ? 2 : 1,
            ),
            boxShadow: tile.isSelected
                ? [
                    BoxShadow(
                      color: colors.secondary.withValues(alpha: 0.45),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  tile.letter,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: tile.isSelected ? colors.onSecondary : colors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Positioned(
                right: 4,
                bottom: 3,
                child: Text(
                  '${tile.pointValue}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: tile.isSelected
                            ? colors.onSecondary.withValues(alpha: 0.85)
                            : colors.onSurfaceVariant,
                        fontSize: 10,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
