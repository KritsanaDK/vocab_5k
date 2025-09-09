import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vocab_5k/Providers/db_provider.dart';
import 'package:vocab_5k/Providers/main_provider.dart';
import '../Helper/app_colors.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int currentQuestion = 0;
  var f = NumberFormat("#,###", "en_US");
  String? selectedOption;
  late FToast fToast;
  MainProvider? mainProvider;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mainProvider ??= Provider.of<MainProvider>(context);
  }

  @override
  void dispose() {
    mainProvider?.stop();
    super.dispose();
  }

  void _showToast(String title, IconData ico, Color col) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: col,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ico, color: Colors.white),
          const SizedBox(width: 16.0),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(milliseconds: 1000),
      fadeDuration: const Duration(milliseconds: 100),
    );
  }

  @override
  Widget build(BuildContext context) {
    var mainProvider = context.watch<MainProvider>();
    var dbProvider = context.watch<DbProvider>();

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.white),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        toolbarHeight: 0,
      ),
      backgroundColor: AppColors.facebookBackground,
      body: SafeArea(
        child: Column(
          children: [
            // คะแนนด้านบน
            Container(
              color: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check, color: Colors.white, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        ": ${f.format(mainProvider.right)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.close, color: Colors.white, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        ": ${f.format(mainProvider.wrong)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // คำถาม
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text:
                            "${mainProvider.index} : ${mainProvider.question?.englishWord} ",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                        children: [
                          if (mainProvider.question?.partOfSpeech != null &&
                              mainProvider.question!.partOfSpeech.isNotEmpty)
                            TextSpan(
                              text: "(${mainProvider.question?.partOfSpeech})",
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await mainProvider.speak(
                        mainProvider.question!.englishWord,
                      );
                    },
                    icon: const Icon(
                      Icons.volume_up,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),

            // ตัวเลือก
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (mainProvider.vocabListRandom.isNotEmpty) ...[
                        Column(
                          children: List.generate(
                            mainProvider.maxChoice,
                            (i) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black87,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 2,
                                  ),
                                  onPressed: () async {
                                    if (mainProvider
                                            .vocabListRandom[i]
                                            .englishWord ==
                                        mainProvider.question?.englishWord) {
                                      _showToast(
                                        "Correct",
                                        Icons.check,
                                        Colors.green,
                                      );
                                      await Future.delayed(
                                        const Duration(milliseconds: 500),
                                      );
                                      await mainProvider
                                          .vocabularyListRandomize(true);
                                      mainProvider.right++;
                                      await dbProvider
                                          .insertOrUpdateResultAddValue(
                                            mainProvider.getDateString(
                                              addDays: 0,
                                            ),
                                            1,
                                            0,
                                          );
                                    } else {
                                      _showToast(
                                        "Wrong",
                                        Icons.close,
                                        Colors.red,
                                      );
                                      mainProvider.wrong++;
                                      await dbProvider
                                          .insertOrUpdateResultAddValue(
                                            mainProvider.getDateString(
                                              addDays: 0,
                                            ),
                                            0,
                                            1,
                                          );
                                    }
                                    setState(() {});
                                  },
                                  child: Text(
                                    "${mainProvider.vocabListRandom[i].thaiMeaning}",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
