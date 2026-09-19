import 'enemy_archetype.dart';

class Enemy {
  const Enemy({
    required this.name,
    required this.hp,
    required this.maxHp,
    required this.baseAttackPower,
    required this.archetype,
  });

  final String name;
  final int hp;
  final int maxHp;
  final int baseAttackPower;
  final EnemyArchetype archetype;

  Enemy copyWith({
    String? name,
    int? hp,
    int? maxHp,
    int? baseAttackPower,
    EnemyArchetype? archetype,
  }) {
    return Enemy(
      name: name ?? this.name,
      hp: hp ?? this.hp,
      maxHp: maxHp ?? this.maxHp,
      baseAttackPower: baseAttackPower ?? this.baseAttackPower,
      archetype: archetype ?? this.archetype,
    );
  }
}