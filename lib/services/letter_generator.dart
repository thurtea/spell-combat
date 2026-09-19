import 'dart:math';

import '../models/difficulty.dart';
import '../models/letter_tile.dart';
import '../utils/letter_values.dart';

class LetterGenerator {
  LetterGenerator({Random? random}) : _random = random ?? Random();

  static const Map<String, int> _letterFrequency = {
    'E': 127,
    'T': 91,
    'A': 82,
    'O': 75,
    'I': 70,
    'N': 67,
    'S': 63,
    'H': 61,
    'R': 60,
    'D': 43,
    'L': 40,
    'C': 28,
    'U': 28,
    'M': 24,
    'W': 24,
    'F': 22,
    'G': 20,
    'Y': 20,
    'P': 19,
    'B': 15,
    'V': 10,
    'K': 8,
    'J': 2,
    'X': 2,
    'Q': 1,
    'Z': 1,
  };

  static const Set<String> _vowels = {'A', 'E', 'I', 'O', 'U'};

  final Random _random;
  int _nextTileId = 0;

  List<LetterTile> generateHand(Difficulty difficulty) {
    final handSize = _handSizeFor(difficulty);
    final letters = <String>[
      _weightedLetter(from: _vowels),
      _weightedLetter(from: _vowels),
    ];

    while (letters.length < handSize) {
      letters.add(_weightedLetter());
    }

    return letters.map((letter) => _createTile(letter)).toList();
  }

  LetterTile generateTile() {
    return _createTile(_weightedLetter());
  }

  LetterTile _createTile(String letter) {
    return LetterTile(
      id: 'tile-${_nextTileId++}',
      letter: letter,
      pointValue: LetterValues.forLetter(letter),
    );
  }

  int _handSizeFor(Difficulty difficulty) {
    return switch (difficulty) {
      Difficulty.easy => 8,
      Difficulty.normal => 9,
      Difficulty.hard => 10 + _random.nextInt(2),
    };
  }

  String _weightedLetter({Set<String>? from}) {
    final availableLetters = from ?? _letterFrequency.keys.toSet();
    final totalWeight = availableLetters.fold<int>(
      0,
      (total, letter) => total + _letterFrequency[letter]!,
    );
    var selection = _random.nextInt(totalWeight);

    for (final letter in availableLetters) {
      selection -= _letterFrequency[letter]!;
      if (selection < 0) return letter;
    }

    return availableLetters.last;
  }
}