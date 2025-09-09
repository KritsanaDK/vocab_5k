import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vocab_5k/Providers/db_provider.dart';
import 'package:vocab_5k/Providers/main_provider.dart';

import 'navigation_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final mainProvider = MainProvider();
  final dbProvider = DbProvider();
  await dbProvider.openDB();

  final value = await dbProvider.getConfigValue("max_choice");
  if (value != null) {
    mainProvider.maxChoice = int.parse(value);
  } else {
    mainProvider.maxChoice = 3; // or some default
  }

  final sound = await dbProvider.getConfigValue("sound");

  print(sound);

  if (sound != null) {
    mainProvider.isOn = bool.parse(sound);
  } else {
    mainProvider.isOn = false; // or some default
  }

  // await dbProvider.deleteResultsLast30DaysAgo();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: mainProvider),
        ChangeNotifierProvider.value(value: dbProvider),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: "Sarabun",
      ),
      home: NavigationBarWidget(),
    );
  }
}
