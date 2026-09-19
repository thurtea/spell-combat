class Player {
  const Player({
    required this.name,
    required this.hp,
    required this.maxHp,
  });

  final String name;
  final int hp;
  final int maxHp;

  Player copyWith({String? name, int? hp, int? maxHp}) {
    return Player(
      name: name ?? this.name,
      hp: hp ?? this.hp,
      maxHp: maxHp ?? this.maxHp,
    );
  }
}