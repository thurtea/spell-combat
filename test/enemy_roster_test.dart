import 'package:flutter_test/flutter_test.dart';
import 'package:spell_combat/data/enemy_roster.dart';
import 'package:spell_combat/models/difficulty.dart';

void main() {
  group('EnemyRoster.starting', () {
    test('always begins a fresh run on the Goblin Scout', () {
      expect(EnemyRoster.starting(), same(EnemyRoster.goblinScout));
    });
  });

  group('EnemyRoster.nextAfter', () {
    test('cycles Goblin Scout -> Flame Salamander -> Ancient Dragon -> Goblin Scout', () {
      expect(EnemyRoster.nextAfter(EnemyRoster.goblinScout), same(EnemyRoster.flameSalamander));
      expect(EnemyRoster.nextAfter(EnemyRoster.flameSalamander), same(EnemyRoster.ancientDragon));
      expect(EnemyRoster.nextAfter(EnemyRoster.ancientDragon), same(EnemyRoster.goblinScout));
    });

    test('falls back to the Goblin Scout for a definition not in encounterOrder', () {
      final stranger = EnemyDefinition(
        enemy: EnemyRoster.goblinScout.enemy,
        assetPrefix: 'not-in-the-roster',
        badgeIcon: 'assets/icons/monster.svg',
        tagline: 'unused',
      );
      expect(EnemyRoster.nextAfter(stranger), same(EnemyRoster.goblinScout));
    });
  });

  group('EnemyRoster.forDifficulty (legacy)', () {
    test('maps each difficulty to its historical single foe', () {
      expect(EnemyRoster.forDifficulty(Difficulty.easy), same(EnemyRoster.goblinScout));
      expect(EnemyRoster.forDifficulty(Difficulty.normal), same(EnemyRoster.flameSalamander));
      expect(EnemyRoster.forDifficulty(Difficulty.hard), same(EnemyRoster.ancientDragon));
    });
  });

  group('EnemyDefinition.spriteForHp', () {
    test('picks the 0hp sprite at zero health', () {
      expect(EnemyRoster.goblinScout.spriteForHp(0, 100), 'assets/icons/goblin-scout-0hp.png');
    });

    test('picks the 50hp sprite at or below 60 percent health', () {
      expect(EnemyRoster.goblinScout.spriteForHp(60, 100), 'assets/icons/goblin-scout-50hp.png');
      expect(EnemyRoster.goblinScout.spriteForHp(1, 100), 'assets/icons/goblin-scout-50hp.png');
    });

    test('picks the 100hp sprite above 60 percent health', () {
      expect(EnemyRoster.goblinScout.spriteForHp(100, 100), 'assets/icons/goblin-scout-100hp.png');
      expect(EnemyRoster.goblinScout.spriteForHp(61, 100), 'assets/icons/goblin-scout-100hp.png');
    });
  });
}
