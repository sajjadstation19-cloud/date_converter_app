import 'package:flutter/material.dart';
import 'package:date_converter_app/l10n/app_localizations.dart';

import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    final start = DateTime.now();
    debugPrint(
        "🚀 [LOG] SplashScreen initState() - ${start.toIso8601String()}");

    // ✅ الانتقال بعد ثانية واحدة
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        final elapsed = DateTime.now().difference(start).inMilliseconds;
        debugPrint("✅ [LOG] الانتقال من Splash بعد ${elapsed}ms");

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("🎨 [LOG] SplashScreen build()");

    final t = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4E7D5B), Color(0xFFE9F3EB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeIn,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✅ شعار التطبيق
                Hero(
                  tag: "app_logo",
                  child: Image.asset(
                    "assets/icon.png",
                    width: 160,
                    height: 160,
                  ),
                ),
                const SizedBox(height: 24),

                // ✅ عنوان التطبيق
                Hero(
                  tag: "app_title",
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      t.appTitle,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ✅ سطر فرعي ديناميكي حسب اللغة
                Text(
                  t.appSubtitle, // ← يجيب من الترجمة
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
