class LetterTile {
  const LetterTile({
    required this.id,
    required this.letter,
    required this.pointValue,
    this.isSelected = false,
  });

  final String id;
  final String letter;
  final int pointValue;
  final bool isSelected;

  LetterTile copyWith({
    String? id,
    String? letter,
    int? pointValue,
    bool? isSelected,
  }) {
    return LetterTile(
      id: id ?? this.id,
      letter: letter ?? this.letter,
      pointValue: pointValue ?? this.pointValue,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}