import 'package:flutter_test/flutter_test.dart';
import 'package:spell_combat/models/letter_tile.dart';
import 'package:spell_combat/services/word_validator.dart';

List<LetterTile> handFor(String letters) {
  return letters
      .split('')
      .asMap()
      .entries
      .map((entry) => LetterTile(id: 't${entry.key}', letter: entry.value, pointValue: 1))
      .toList();
}

void main() {
  final validator = WordValidator();

  group('WordValidator.isValid', () {
    test('accepts a real word whose letters are all in hand', () {
      expect(validator.isValid(word: 'CAT', currentHand: handFor('CATDOG')), isTrue);
    });

    test('rejects a word shorter than the minimum length', () {
      expect(validator.isValid(word: 'AT', currentHand: handFor('AT')), isFalse);
    });

    test('rejects a word not in the dictionary', () {
      expect(validator.isValid(word: 'ZZZ', currentHand: handFor('ZZZAAA')), isFalse);
    });

    test('rejects a word that reuses a letter more times than the hand has it', () {
      // "ADD" needs two D's; the hand only has one.
      expect(validator.isValid(word: 'ADD', currentHand: handFor('ADXYZQ')), isFalse);
    });

    test('is case-insensitive on both the word and the hand', () {
      expect(validator.isValid(word: 'cat', currentHand: handFor('catdog')), isTrue);
    });

    test('rejects a word using a letter not present in the hand at all', () {
      expect(validator.isValid(word: 'CAT', currentHand: handFor('COW')), isFalse);
    });

    test('trims surrounding whitespace before validating', () {
      expect(validator.isValid(word: '  cat  ', currentHand: handFor('CATDOG')), isTrue);
    });
  });

  group('WordValidator with a custom dictionary', () {
    test('honors an injected WordDictionary instead of the embedded one', () {
      final custom = WordValidator(
        dictionary: _FakeDictionary({'zap'}),
      );
      expect(custom.isValid(word: 'ZAP', currentHand: handFor('ZAPXYZ')), isTrue);
      expect(custom.isValid(word: 'CAT', currentHand: handFor('CATXYZ')), isFalse);
    });
  });
}

class _FakeDictionary implements WordDictionary {
  _FakeDictionary(this._words);
  final Set<String> _words;

  @override
  bool contains(String word) => _words.contains(word);
}
