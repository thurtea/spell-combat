import '../../models/letter_tile.dart';
import 'enemy_archetype_hook.dart';

class MimicHook extends NoOpEnemyArchetypeHook {
  MimicHook();

  List<LetterTile> _nextAttackLetters = const [];

  @override
  void onPlayerWordSubmitted(List<LetterTile> usedTiles) {
    _nextAttackLetters = List.unmodifiable(usedTiles);
  }

  @override
  int consumeAdditionalAttackPower() {
    final bonus = _nextAttackLetters.fold<int>(
      0,
      (total, tile) => total + tile.pointValue,
    );
    _nextAttackLetters = const [];
    return bonus;
  }
}