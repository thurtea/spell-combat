enum EnemyArchetype {
  shielded,
  vowelEater,
  berserker,
  mimic,
}

extension EnemyArchetypeLabel on EnemyArchetype {
  String get label => switch (this) {
        EnemyArchetype.shielded => 'Shielded',
        EnemyArchetype.vowelEater => 'Vowel Eater',
        EnemyArchetype.berserker => 'Berserker',
        EnemyArchetype.mimic => 'Mimic',
      };
}