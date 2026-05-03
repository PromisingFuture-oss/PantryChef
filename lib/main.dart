import 'package:flutter/material.dart';
import 'utils/theme.dart';
import 'screens/home_page.dart';

void main() {
  runApp(const PantryChefApp());
}

class PantryChefApp extends StatelessWidget {
  const PantryChefApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pantry Chef',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getLightTheme(),
      home: const PantryChefHomePage(),
    );
  }
}
