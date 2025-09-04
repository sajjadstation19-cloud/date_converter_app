import 'package:flutter/material.dart';
import 'package:date_converter_app/l10n/app_localizations.dart';

import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // ✅ الانتقال بعد نصف ثانية (شعور طبيعي بوجود Splash)
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF4E7D5B),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ شعار التطبيق من assets بدل الأيقونة الافتراضية
            Hero(
              tag: "app_logo",
              child: Image.asset(
                "assets/icon.png",
                width: 120,
                height: 120,
              ),
            ),
            const SizedBox(height: 20),

            // ✅ عنوان التطبيق مع Hero + ترجمة
            Hero(
              tag: "app_title",
              child: Material(
                color: Colors.transparent,
                child: Text(
                  t.appTitle,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
