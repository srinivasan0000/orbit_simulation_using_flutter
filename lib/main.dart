import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color.fromARGB(255, 22, 23, 23),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(backgroundColor: Colors.blueGrey[900]),
        sliderTheme: const SliderThemeData(
          activeTrackColor: Colors.purple,
          thumbColor: Colors.purple,
        ),
      ),
      home: const GravityOrbitSimulation(),
    );
  }
}
