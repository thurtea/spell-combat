import '../models/letter_tile.dart';

class DamageConstants {
  const DamageConstants._();

  static const int minimumLengthBonus = 5;
  static const int minimumLargeLengthBonus = 7;
  static const int lengthBonus = 10;
  static const int largeLengthBonus = 20;
  static const int bingoBonus = 25;
  static const int comboThreshold = 3;
  static const int highComboThreshold = 5;
  static const double comboMultiplier = 1.25;
  static const double highComboMultiplier = 1.5;
  static const int powerWordBonus = 25;
}

class DamageCalculator {
  const DamageCalculator();

  int calculateDamage({
    required List<LetterTile> usedTiles,
    required List<LetterTile> currentHand,
    required int comboCount,
    bool isPowerWord = false,
  }) {
    final baseDamage = usedTiles.fold<int>(
      0,
      (total, tile) => total + tile.pointValue,
    );
    final wordLength = usedTiles.length;
    final lengthBonus = _lengthBonus(wordLength);
    final bingoBonus = _isBingo(usedTiles, currentHand)
        ? DamageConstants.bingoBonus
        : 0;
    final comboMultiplier = _comboMultiplier(comboCount);
    final calculatedDamage =
        (baseDamage + lengthBonus + bingoBonus) * comboMultiplier;
    final powerWordBonus = isPowerWord ? DamageConstants.powerWordBonus : 0;

    return calculatedDamage.round() + powerWordBonus;
  }

  int _lengthBonus(int wordLength) {
    if (wordLength >= DamageConstants.minimumLargeLengthBonus) {
      return DamageConstants.largeLengthBonus;
    }
    if (wordLength >= DamageConstants.minimumLengthBonus) {
      return DamageConstants.lengthBonus;
    }
    return 0;
  }

  double _comboMultiplier(int comboCount) {
    if (comboCount >= DamageConstants.highComboThreshold) {
      return DamageConstants.highComboMultiplier;
    }
    if (comboCount >= DamageConstants.comboThreshold) {
      return DamageConstants.comboMultiplier;
    }
    return 1.0;
  }

  bool _isBingo(List<LetterTile> usedTiles, List<LetterTile> currentHand) {
    if (currentHand.isEmpty) return false;

    final usedTileIds = usedTiles.map((tile) => tile.id).toSet();
    return currentHand.every((tile) => usedTileIds.contains(tile.id));
  }
}