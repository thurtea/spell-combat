import 'enemy_archetype_hook.dart';

class ShieldedHook extends NoOpEnemyArchetypeHook {
  const ShieldedHook();

  static const double shortWordDamageMultiplier = 0.5;

  @override
  int modifyIncomingDamage({required int damage, required int wordLength}) {
    if (wordLength >= 5) return damage;
    return (damage * shortWordDamageMultiplier).round();
  }
}