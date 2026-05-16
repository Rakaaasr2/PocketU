import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart'; // <--- 1. FIX: Path import ditambah 'screens/'

void main() {
  runApp(const PocketUApp());
}

class PocketUApp extends StatelessWidget {
  const PocketUApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PocketU',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
      ),

      // 2. FIX: Diubah jadi nama Class-nya dengan Huruf Kapital, tanpa const
      home: SplashScreen(),
    );
  }
}