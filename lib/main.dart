import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rateexchangelive/screens/home_screen.dart';
import 'package:rateexchangelive/theme/app_theme.dart';
import 'package:rateexchangelive/services/currency_service.dart'; // ← ADD

void main() async { // ← ADD async
  WidgetsFlutterBinding.ensureInitialized();
  await CurrencyService.debugApiCheck(); // ← ADD (prints live check to console)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const RateRushApp());
}

class RateRushApp extends StatefulWidget {
  const RateRushApp({super.key});

  @override
  State<RateRushApp> createState() => _RateRushAppState();
}

class _RateRushAppState extends State<RateRushApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void toggleTheme() {
    setState(() {
      _themeMode =
      _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RateRush',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: _themeMode,
      home: HomeScreen(onToggleTheme: toggleTheme),
    );
  }
}