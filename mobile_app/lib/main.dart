import 'package:flutter/material.dart';
import 'screens/players_list_screen.dart';

void main() {
  runApp(const TiraTimeApp());
}

class TiraTimeApp extends StatelessWidget {
  const TiraTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciador de Racha',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
      ),
      home: const PlayersListScreen(),
    );
  }
}
