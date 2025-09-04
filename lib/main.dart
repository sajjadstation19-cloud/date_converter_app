import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

// Helpers
import 'utils/ad_helper.dart'; // ✅ إعلان App Open

// Localization
import 'package:date_converter_app/l10n/app_localizations.dart';

// Screens & Providers
import 'screens/splash_screen.dart'; // ✅ نستخدم SplashScreen كبداية
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';

// ✅ AdMob
import 'package:google_mobile_ads/google_mobile_ads.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 AdMob
  await MobileAds.instance.initialize();

  // ✅ تحميل إعلان App Open
  AdHelper.loadAppOpenAd();

  // تحميل إعدادات الثيم واللغة
  final themeProvider = ThemeProvider();
  final localeProvider = LocaleProvider();

  await Future.wait([themeProvider.load(), localeProvider.load()]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final localeProv = context.watch<LocaleProvider>();

    // ✅ بعد ما تجهز الشاشة استعرض إعلان الفتح
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdHelper.showAppOpenAd();
    });

    final t = AppLocalizations.of(context);

    return MaterialApp(
      title: t.appTitle.isNotEmpty ? t.appTitle : 'Date Converter',
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
          backgroundColor: Color(0xFF4E7D5B), // ✅ لون أخضر ثابت
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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
          backgroundColor: Color(0xFF4E7D5B), // ✅ نفس اللون بالـ Dark
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
      ),

      // 🏠 شاشة البداية → بعدها تتحول لـ HomeScreen
      home: const SplashScreen(),
    );
  }
}
