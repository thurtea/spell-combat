import '../../models/enemy.dart';
import '../../models/letter_tile.dart';
import '../letter_generator.dart';

abstract interface class EnemyArchetypeHook {
  int modifyIncomingDamage({
    required int damage,
    required int wordLength,
  });

  List<LetterTile> onEnemyTurnStart({
    required List<LetterTile> currentHand,
    required LetterGenerator letterGenerator,
  });

  int enemyAttackPower({required Enemy enemy});

  void onPlayerWordSubmitted(List<LetterTile> usedTiles);

  int consumeAdditionalAttackPower();
}

abstract class NoOpEnemyArchetypeHook implements EnemyArchetypeHook {
  const NoOpEnemyArchetypeHook();

  @override
  int modifyIncomingDamage({required int damage, required int wordLength}) => damage;

  @override
  List<LetterTile> onEnemyTurnStart({
    required List<LetterTile> currentHand,
    required LetterGenerator letterGenerator,
  }) => currentHand;

  @override
  int enemyAttackPower({required Enemy enemy}) => enemy.baseAttackPower;

  @override
  void onPlayerWordSubmitted(List<LetterTile> usedTiles) {}

  @override
  int consumeAdditionalAttackPower() => 0;
}