import 'package:flutter/material.dart';
import 'constants.dart';
 // Ini harus diimpor karena nanti dipakai di Navigator
import 'pages/splash_page.dart';

void main() {
  runApp(const SAPModernApp());
}

class SAPModernApp extends StatelessWidget {
  const SAPModernApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Segoe UI',
        colorSchemeSeed: AppColors.primaryIndigo,
      ),
      // 🔥 PINTU MASUK UTAMA ADALAH SPLASH
      home: const SplashPage(), 
    );
  }
}