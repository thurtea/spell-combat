import 'package:flutter_test/flutter_test.dart';
import 'package:spell_combat/models/difficulty.dart';
import 'package:spell_combat/services/battle_controller.dart';

void main() {
  group('BattleController.shuffleHand', () {
    test('replaces the hand, clears the current word, and spends a charge', () {
      final controller = BattleController(difficulty: Difficulty.easy);
      final chargesBefore = controller.state.shuffleCharges;
      controller.selectLetter(controller.state.currentHand.first.id);
      expect(controller.state.currentWord.text, isNotEmpty);

      final result = controller.shuffleHand();

      expect(result, isTrue);
      expect(controller.state.shuffleCharges, chargesBefore - 1);
      expect(controller.state.currentWord.text, isEmpty);
      expect(controller.state.currentHand.every((tile) => !tile.isSelected), isTrue);
    });

    test('fails once shuffle charges are exhausted', () {
      final controller = BattleController(difficulty: Difficulty.hard);
      // Hard starts with exactly 1 shuffle charge.
      expect(controller.shuffleHand(), isTrue);
      expect(controller.state.shuffleCharges, 0);
      expect(controller.shuffleHand(), isFalse);
    });
  });

  group('BattleController.rerollTile', () {
    test('replaces exactly one tile, keeps the rest, and spends a charge', () {
      final controller = BattleController(difficulty: Difficulty.easy);
      final chargesBefore = controller.state.rerollCharges;
      final handBefore = controller.state.currentHand;
      final targetId = handBefore.first.id;
      final otherIds = handBefore.skip(1).map((t) => t.id).toSet();

      final result = controller.rerollTile(targetId);

      expect(result, isTrue);
      expect(controller.state.rerollCharges, chargesBefore - 1);
      expect(controller.state.currentHand.length, handBefore.length);
      // The rerolled slot has a brand new id; every other tile's id survives.
      expect(controller.state.currentHand.any((t) => t.id == targetId), isFalse);
      expect(
        controller.state.currentHand.map((t) => t.id).toSet().intersection(otherIds),
        otherIds,
      );
    });

    test('removes a rerolled tile from the word in progress if it was selected', () {
      final controller = BattleController(difficulty: Difficulty.easy);
      final targetId = controller.state.currentHand.first.id;
      controller.selectLetter(targetId);
      expect(controller.state.currentWord.tileIds, contains(targetId));

      controller.rerollTile(targetId);

      expect(controller.state.currentWord.tileIds, isNot(contains(targetId)));
    });

    test('fails for a tile id that is not in the current hand', () {
      final controller = BattleController(difficulty: Difficulty.easy);
      expect(controller.rerollTile('not-a-real-tile-id'), isFalse);
    });

    test('fails once reroll charges are exhausted', () {
      final controller = BattleController(difficulty: Difficulty.hard);
      // Hard starts with exactly 1 reroll charge.
      final firstId = controller.state.currentHand.first.id;
      expect(controller.rerollTile(firstId), isTrue);
      expect(controller.state.rerollCharges, 0);
      final anyId = controller.state.currentHand.first.id;
      expect(controller.rerollTile(anyId), isFalse);
    });
  });
}
