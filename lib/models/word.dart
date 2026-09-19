class Word {
  const Word({this.text = '', this.tileIds = const []});

  final String text;
  final List<String> tileIds;

  bool get isEmpty => text.isEmpty;

  Word copyWith({String? text, List<String>? tileIds}) {
    return Word(
      text: text ?? this.text,
      tileIds: List.unmodifiable(tileIds ?? this.tileIds),
    );
  }
}