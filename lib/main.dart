import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sizer/sizer.dart';
import 'package:easy_localization/easy_localization.dart'; // 1. Pastikan import ini ada

import '../core/app_export.dart';
import '../widgets/custom_error_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // --- LOKALISASI: Wajib inisialisasi di sini ---
  await EasyLocalization.ensureInitialized(); 
  // ----------------------------------------------

  bool _hasShownError = false;

  // 🚨 CRITICAL: Custom error handling - DO NOT REMOVE
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (!_hasShownError) {
      _hasShownError = true;

      // Reset flag after 3 seconds to allow error widget on new screens
      Future.delayed(Duration(seconds: 5), () {
        _hasShownError = false;
      });

      return CustomErrorWidget(errorDetails: details);
    }
    return SizedBox.shrink();
  };

  // 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE
  Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
  ]).then((value) {
    runApp(
      // --- LOKALISASI: Bungkus MyApp dengan EasyLocalization ---
      EasyLocalization(
        supportedLocales: [
          Locale('en', 'US'), // Inggris (Default)
          Locale('id', 'ID'), // Indonesia
          Locale('ja', 'JP'), // Jepang
          Locale('ms', 'MY'), // Malaysia
          Locale('zh', 'CN'), // China (Mandarin)
          Locale('ko', 'KR'), // Korea
          Locale('ar', 'SA'), // Arab
          Locale('es', 'ES'), // Spanyol
          Locale('fr', 'FR'), // Prancis
          Locale('de', 'DE'), // Jerman
          Locale('it', 'IT'), // Italia
          Locale('th', 'TH'), // Thailand
          Locale('tr', 'TR'), // Turki
          Locale('hi', 'IN'), // Hindi
          Locale('ru', 'RU'), // Rusia
        ],
        path: 'assets/translations', // Lokasi folder JSON
        fallbackLocale: Locale('en', 'US'), // Jika bahasa HP user aneh, pakai Inggris
        startLocale: null, // Biarkan NULL agar OTOMATIS deteksi HP user
        child: MyApp(),
      ),
      // ---------------------------------------------------------
    );
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          // --- LOKALISASI: Sambungkan Config ke MaterialApp ---
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale, // Ini yang bikin bahasa berubah otomatis
          // ----------------------------------------------------

          title: 'WalletCard Pro',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,

          // 🚨 CRITICAL: NEVER REMOVE OR MODIFY
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.0)),
              child: child!,
            );
          },
          // 🚨 END CRITICAL SECTION
          debugShowCheckedModeBanner: false,
          routes: AppRoutes.routes,
          initialRoute: AppRoutes.initial,
        );
      },
    );
  }
}