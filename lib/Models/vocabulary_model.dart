class VocabularyModel {
  final String englishWord;
  final String thaiMeaning;
  final String partOfSpeech;

  VocabularyModel({
    required this.englishWord,
    required this.thaiMeaning,
    required this.partOfSpeech,
  });

  factory VocabularyModel.fromJson(Map<String, dynamic> json) {
    return VocabularyModel(
      englishWord: json['EnglishWord'],
      thaiMeaning: json['ThaiMeaning'],
      partOfSpeech: json['PartOfSpeech'],
    );
  }

  @override
  String toString() {
    return 'VocabularyModel(englishWord: $englishWord, thaiMeaning: $thaiMeaning, partOfSpeech: $partOfSpeech)';
  }
}
