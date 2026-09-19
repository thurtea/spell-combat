import '../models/difficulty.dart';
import '../models/enemy.dart';
import '../models/enemy_archetype.dart';

/// Static definition of an enemy encounter: stats, archetype, and art.
class EnemyDefinition {
  const EnemyDefinition({
    required this.enemy,
    required this.assetPrefix,
    required this.badgeIcon,
    required this.tagline,
  });

  final Enemy enemy;

  /// Prefix used to build `assets/icons/<prefix>-<hpBucket>hp.png`.
  final String assetPrefix;

  /// Small vector badge shown beside the enemy nameplate.
  final String badgeIcon;

  final String tagline;

  /// Picks the closest sprite for the enemy's current HP percentage.
  String spriteForHp(int hp, int maxHp) {
    final ratio = maxHp == 0 ? 0.0 : hp / maxHp;
    final bucket = ratio <= 0
        ? 0
        : ratio <= 0.6
            ? 50
            : 100;
    return 'assets/icons/$assetPrefix-${bucket}hp.png';
  }
}

/// Encounter roster. Difficulty tunes player resources; foes rotate per run.
class EnemyRoster {
  const EnemyRoster._();

  static const EnemyDefinition goblinScout = EnemyDefinition(
    enemy: Enemy(
      name: 'Goblin Scout',
      hp: 100,
      maxHp: 100,
      baseAttackPower: 8,
      archetype: EnemyArchetype.shielded,
    ),
    assetPrefix: 'goblin-scout',
    badgeIcon: 'assets/icons/monster.svg',
    tagline: 'Raises its buckler against short words.',
  );

  static const EnemyDefinition flameSalamander = EnemyDefinition(
    enemy: Enemy(
      name: 'Flame Salamander',
      hp: 115,
      maxHp: 115,
      baseAttackPower: 10,
      archetype: EnemyArchetype.vowelEater,
    ),
    assetPrefix: 'flame-salamander',
    badgeIcon: 'assets/icons/lizard.svg',
    tagline: 'Scorches a vowel from your hand every turn.',
  );

  static const EnemyDefinition ancientDragon = EnemyDefinition(
    enemy: Enemy(
      name: 'Ancient Dragon',
      hp: 160,
      maxHp: 160,
      baseAttackPower: 13,
      archetype: EnemyArchetype.berserker,
    ),
    assetPrefix: 'ancient-dragon',
    badgeIcon: 'assets/icons/dragon.svg',
    tagline: 'Grows more ferocious as its health drops.',
  );

  /// Fight order: always begin a fresh session on the Goblin Scout.
  static const List<EnemyDefinition> encounterOrder = [
    goblinScout,
    flameSalamander,
    ancientDragon,
  ];

  /// First battle of a run always starts with the Goblin Scout.
  static EnemyDefinition starting() => goblinScout;

  /// Next foe after [current] (cycles). Used on Play Again.
  static EnemyDefinition nextAfter(EnemyDefinition current) {
    final index = encounterOrder.indexWhere(
      (definition) => definition.assetPrefix == current.assetPrefix,
    );
    if (index < 0) return goblinScout;
    return encounterOrder[(index + 1) % encounterOrder.length];
  }

  /// Legacy mapping kept for callers that still key off difficulty.
  /// Prefer [starting] / [nextAfter] for new battles.
  static EnemyDefinition forDifficulty(Difficulty difficulty) {
    return switch (difficulty) {
      Difficulty.easy => goblinScout,
      Difficulty.normal => flameSalamander,
      Difficulty.hard => ancientDragon,
    };
  }
}
