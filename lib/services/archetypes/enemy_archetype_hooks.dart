import '../../models/enemy_archetype.dart';
import 'berserker_hook.dart';
import 'enemy_archetype_hook.dart';
import 'mimic_hook.dart';
import 'shielded_hook.dart';
import 'vowel_eater_hook.dart';

Map<EnemyArchetype, EnemyArchetypeHook> createEnemyArchetypeHooks() {
  return {
    EnemyArchetype.shielded: const ShieldedHook(),
    EnemyArchetype.vowelEater: VowelEaterHook(),
    EnemyArchetype.berserker: const BerserkerHook(),
    EnemyArchetype.mimic: MimicHook(),
  };
}