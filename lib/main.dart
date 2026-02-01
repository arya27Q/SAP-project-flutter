import 'package:flutter/material.dart';
import 'constants.dart';

// Import DUA-DUANYA
import 'desktop/pages/splash_page.dart'; 
import 'tablet/tablet_splash_page.dart';

void main() {
  runApp(const SAPModernApp());
}

class SAPModernApp extends StatelessWidget {
  const SAPModernApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QC System',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Segoe UI',
        colorSchemeSeed: AppColors.primaryIndigo,
      ),
      
      //  LOGIC DETEKSI LAYAR 
      home: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 1000) {
            return const SplashPage(); 
          } 
          else {
            return const TabletSplashPage(); 
          }
        },
      ),
    );
  }
}