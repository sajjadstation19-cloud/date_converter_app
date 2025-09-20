import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

// Helpers
import 'utils/ad_helper.dart'; // ✅ إعلان App Open

// Localization
import 'package:date_converter_app/l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';

// ✅ AdMob
import 'package:google_mobile_ads/google_mobile_ads.dart';

Future<void> main() async {
  final startTime = DateTime.now();
  debugPrint("⏱️ [LOG] main() بدأ: $startTime");

  WidgetsFlutterBinding.ensureInitialized();

  // تحميل إعدادات الثيم واللغة
  final themeProvider = ThemeProvider();
  final localeProvider = LocaleProvider();
  await Future.wait([themeProvider.load(), localeProvider.load()]);

  debugPrint(
      "✅ [LOG] Providers تهيأت بعد: ${DateTime.now().difference(startTime).inMilliseconds}ms");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
      ],
      child: const MyApp(),
    ),
  );

  debugPrint(
      "🎯 [LOG] runApp() استدعيت بعد: ${DateTime.now().difference(startTime).inMilliseconds}ms");

  // ✅ هيئ AdMob بعد تشغيل الواجهة
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await MobileAds.instance.initialize();
    debugPrint(
        "✅ [LOG] MobileAds تهيأت بعد: ${DateTime.now().difference(startTime).inMilliseconds}ms");

    // ✅ نحمل كل أنواع الإعلانات مرة وحدة
    AdHelper.preloadAllAds();

    // ✅ نحمل إعلان الفتح بشكل صريح (يبقى موجود)
    AdHelper.loadAppOpenAd();
    debugPrint("✅ [LOG] AppOpenAd انطلب تحميله");
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final localeProv = context.watch<LocaleProvider>();

    // ✅ استعرض إعلان الفتح بعد أول إطار
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint("👋 [LOG] أول إطار انبنى (build MyApp)");
      AdHelper.showAppOpenAd();
    });

    return MaterialApp(
      // 🔹 عنوان افتراضي
      title: 'Date Converter',
      debugShowCheckedModeBanner: false,

      // 🌍 اللغة
      locale: localeProv.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // 🎨 الثيم
      themeMode: themeProv.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4E7D5B),
          brightness: Brightness.light,
        ),
        fontFamily: 'Tajawal',
        scaffoldBackgroundColor: const Color(0xFFF8F8F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4E7D5B),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: const CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          elevation: 2,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4E7D5B),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Tajawal',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4E7D5B),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: const CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          elevation: 2,
        ),
      ),

      // 🏠 شاشة البداية
      home: const HomeScreen(),
    );
  }
}
