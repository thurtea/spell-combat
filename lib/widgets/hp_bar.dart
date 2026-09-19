import 'package:flutter/material.dart';

/// Animated HP bar with a numeric readout, used for both player and enemy.
class HpBar extends StatelessWidget {
  const HpBar({
    required this.hp,
    required this.maxHp,
    required this.color,
    super.key,
  });

  final int hp;
  final int maxHp;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ratio = maxHp == 0 ? 0.0 : (hp / maxHp).clamp(0.0, 1.0);
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            children: [
              Container(height: 14, color: colors.outlineVariant.withValues(alpha: 0.4)),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: ratio, end: ratio),
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => FractionallySizedBox(
                  widthFactor: value,
                  child: Container(
                    height: 14,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withValues(alpha: 0.75), color],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$hp / $maxHp HP',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}
