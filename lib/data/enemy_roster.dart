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

/// Maps each difficulty tier to its signature foe.
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
      hp: 130,
      maxHp: 130,
      baseAttackPower: 12,
      archetype: EnemyArchetype.vowelEater,
    ),
    assetPrefix: 'flame-salamander',
    badgeIcon: 'assets/icons/lizard.svg',
    tagline: 'Scorches a vowel from your hand every turn.',
  );

  static const EnemyDefinition ancientDragon = EnemyDefinition(
    enemy: Enemy(
      name: 'Ancient Dragon',
      hp: 170,
      maxHp: 170,
      baseAttackPower: 14,
      archetype: EnemyArchetype.berserker,
    ),
    assetPrefix: 'ancient-dragon',
    badgeIcon: 'assets/icons/dragon.svg',
    tagline: 'Grows more ferocious as its health drops.',
  );

  static EnemyDefinition forDifficulty(Difficulty difficulty) {
    return switch (difficulty) {
      Difficulty.easy => goblinScout,
      Difficulty.normal => flameSalamander,
      Difficulty.hard => ancientDragon,
    };
  }
}
