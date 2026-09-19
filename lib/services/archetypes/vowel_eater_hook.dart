import 'dart:math';

import '../../models/letter_tile.dart';
import '../letter_generator.dart';
import 'enemy_archetype_hook.dart';

class VowelEaterHook extends NoOpEnemyArchetypeHook {
  VowelEaterHook({Random? random}) : _random = random ?? Random();

  static const _vowels = {'A', 'E', 'I', 'O', 'U'};
  final Random _random;

  @override
  List<LetterTile> onEnemyTurnStart({
    required List<LetterTile> currentHand,
    required LetterGenerator letterGenerator,
  }) {
    final vowelIndexes = <int>[];
    for (var index = 0; index < currentHand.length; index++) {
      if (_vowels.contains(currentHand[index].letter.toUpperCase())) {
        vowelIndexes.add(index);
      }
    }
    if (vowelIndexes.isEmpty) return currentHand;

    final removedIndex = vowelIndexes[_random.nextInt(vowelIndexes.length)];
    final updatedHand = [...currentHand]..removeAt(removedIndex);
    updatedHand.add(letterGenerator.generateTile());
    return updatedHand;
  }
}