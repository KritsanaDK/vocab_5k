import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vocab_5k/models/vocabulary_model.dart';

class MainProvider with ChangeNotifier {
  List<VocabularyModel> vocabList = [];
  List<VocabularyModel> vocabListRandom = [];

  // ประกาศตัวแปร poolIndex ใน MainProvider
  List<int> _poolIndex = [];
  VocabularyModel? question;
  int maxChoice = 3;
  int index = 1;
  int right = 0;
  int wrong = 0;
  bool isOn = false;
  bool isPremium = false;

  Future<void> loadVocabularyList() async {
    print("loadVocabularyList");
    final String jsonString = await rootBundle.loadString(
      'assets/files/Daily_English_5000_Words.json',
    );
    final List<dynamic> jsonList = json.decode(jsonString);

    vocabList = jsonList.map((item) => VocabularyModel.fromJson(item)).toList();
    // vocabListRandom = vocabList;
    vocabularyListRandomize(false);
    notifyListeners();
  }

  Future<void> vocabularyListRandomize(bool page) async {
    if (vocabList.isEmpty) return;

    Random random = Random();

    // กำหนดจำนวนสูงสุดสำหรับการสุ่ม
    int maxIndex =
        isPremium
            ? vocabList
                .length // Premium: random ทั้งหมด
            : (vocabList.length > 50
                ? 50
                : vocabList.length); // Non-Premium: max 50

    // จำนวนตัวเลือกในรอบนี้
    int choiceCount = maxChoice < maxIndex ? maxChoice : maxIndex;

    // สร้าง pool ของ index และ shuffle
    List<int> pool = List.generate(maxIndex, (i) => i);
    pool.shuffle(random);

    // เลือก unique index
    List<int> uniqueIndexes = pool.take(choiceCount).toList();

    // สร้าง vocabListRandom
    vocabListRandom
      ..clear()
      ..addAll(uniqueIndexes.map((i) => vocabList[i]));

    // เลือกคำถามสุ่มจาก vocabListRandom
    question = vocabListRandom[random.nextInt(choiceCount)];

    if (isOn && page) {
      await speak(question!.englishWord);
    }

    if (page) {
      index++;
    }

    notifyListeners();
  }

  String getDateString({int addDays = 0}) {
    final now = DateTime.now().add(Duration(days: addDays));
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  final FlutterTts flutterTts = FlutterTts();

  Future<void> speak(String text) async {
    await flutterTts.setLanguage("en-US"); // ภาษา
    await flutterTts.setPitch(1.0); // ความสูงต่ำของเสียง
    await flutterTts.setSpeechRate(0.5); // ความเร็วพูด
    await flutterTts.speak(text);
  }

  Future<void> stop() async {
    await flutterTts.stop();
  }

  Future<void> setLanguage(String languageCode) async {
    await flutterTts.setLanguage(languageCode);
    notifyListeners();
  }

  Future<void> setSpeechRate(double rate) async {
    await flutterTts.setSpeechRate(rate);
    notifyListeners();
  }

  Future<void> setPitch(double pitch) async {
    await flutterTts.setPitch(pitch);
    notifyListeners();
  }

  void unlockPremium() {
    isPremium = true;
    notifyListeners();
  }
}
