import '../../models/enemy.dart';
import 'enemy_archetype_hook.dart';

class BerserkerHook extends NoOpEnemyArchetypeHook {
  const BerserkerHook();

  static const double lowHealthThreshold = 0.5;
  static const double lowHealthAttackMultiplier = 1.5;

  @override
  int enemyAttackPower({required Enemy enemy}) {
    if (enemy.maxHp <= 0) return enemy.baseAttackPower;
    final healthRatio = enemy.hp / enemy.maxHp;
    if (healthRatio >= lowHealthThreshold) return enemy.baseAttackPower;
    return (enemy.baseAttackPower * lowHealthAttackMultiplier).round();
  }
}