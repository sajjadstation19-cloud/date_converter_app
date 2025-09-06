import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // ✅ Ads
import 'package:date_converter_app/l10n/app_localizations.dart';

import '../widgets/conversion_bottom_sheet.dart';
import '../widgets/date_result_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/settings_bottom_sheet.dart';
import '../models/conversion_output.dart';

import '../utils/occasions.dart';
import '../utils/date_utils.dart';
import '../utils/ad_helper.dart'; // ✅ استدعاء ملف الإعلانات

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;
  late final Animation<double> _scaleIn;

  ConversionOutput? _lastResult;

  // ✅ Banner Ad
  BannerAd? _bannerAd;
  bool _isBannerReady = false;

  // ✅ Interstitial Ad counter
  int _conversionCount = 0;

  // ✅ انتظار إعلان المزيد
  bool _isLoadingAd = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, .12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _scaleIn = Tween<double>(
      begin: .97,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    // ✅ تحميل إعلان بانر
    _bannerAd = AdHelper.createBannerAd(
      onLoaded: () {
        setState(() => _isBannerReady = true);
      },
    );

    // ✅ تحميل Interstitial Ad
    AdHelper.loadInterstitialAd();

    // ✅ تحميل Rewarded Interstitial Ad
    AdHelper.loadRewardedInterstitialAd();
  }

  @override
  void dispose() {
    _controller.dispose();
    _bannerAd?.dispose(); // ✅ تنظيف الإعلان
    super.dispose();
  }

  /// إعلان مكافأة (إجباري عند الضغط على زر المزيد)
  void _showRewardedAd() {
    Feedback.forTap(context);
    setState(() => _isLoadingAd = true);

    AdHelper.showRewardedInterstitialAd(() {
      setState(() => _isLoadingAd = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("🎬 ${AppLocalizations.of(context).watchAdReward}"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }, onFail: () {
      setState(() => _isLoadingAd = false);
    });
  }

  Future<void> _openConversion({required bool fromGregorian}) async {
    Feedback.forTap(context);
    final result = await showModalBottomSheet<ConversionOutput>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => ConversionBottomSheet(fromGregorian: fromGregorian),
    );

    if (!mounted) return;

    if (result != null) {
      setState(() {
        _lastResult = result;
        _conversionCount++;
      });

      // ✅ كل 3 مرات يفتح إعلان Interstitial
      if (_conversionCount % 3 == 0) {
        AdHelper.showInterstitialAd();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // تاريخ اليوم
    final today = DateUtilsX.getToday();

    // ✅ اختيار اللغة
    final isAr = Localizations.localeOf(context).languageCode == "ar";

    // ميلادي
    final g = today.gregorian;
    final gMonthName = DateUtilsHelper.getMonthName(g.month, isAr: isAr);
    final gregText = '${g.year} ($gMonthName ${g.day})';

    // هجري
    final h = today.hijri;
    final hMonthName = DateUtilsX.hijriMonthsAr[h.hMonth - 1];
    final hijriText = '${h.hYear} هـ ($hMonthName ${h.hDay})';

    // المناسبات
    final hijriKey = getHijriOccasionKey(today.hijri);
    final gregKeys = getGregorianOccasionKeys(today.gregorian);

    final hijriOccasions = <String>[
      if (hijriKey != null) _translateOccasion(hijriKey, t),
    ];
    final gregorianOccasions =
        gregKeys.map((k) => _translateOccasion(k, t)).toList();

    // ✅ اختيار اليوم حسب اللغة
    final weekday = isAr
        ? DateUtilsX.weekdayArOf(today.gregorian)
        : DateUtilsX.weekdayEnOf(today.gregorian);

    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Feedback.forTap(context),
          child: const Hero(
            tag: "app_logo",
            child: Icon(
              Icons.calendar_month,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        title: Hero(
          tag: "app_title",
          child: Material(
            color: Colors.transparent,
            child: Text(
              t.appTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        backgroundColor: const Color(0xFF4E7D5B),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            tooltip: t.settings,
            onPressed: () {
              Feedback.forTap(context);
              showModalBottomSheet(
                context: context,
                useSafeArea: true,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (ctx) => const SettingsBottomSheet(),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8F8F5), Color(0xFFE9F3EB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // بطاقة اليوم
                    SlideTransition(
                      position: _slideUp,
                      child: FadeTransition(
                        opacity: _fadeIn,
                        child: ScaleTransition(
                          scale: _scaleIn,
                          child: _TodayCard(
                            weekday: weekday,
                            gregTitle:
                                "${t.todayGregorianTitle} ${t.todayWord}",
                            gregText: gregText,
                            gregOccasions: gregorianOccasions,
                            hijriTitle: "${t.todayHijriTitle} ${t.todayWord}",
                            hijriText: hijriText,
                            hijriOccasions: hijriOccasions,
                            showApproxNote:
                                today.approximate ? t.noteAccuracy : null,
                            textTheme: textTheme,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // أزرار التحويل
                    _animatedButton(
                      context: context,
                      icon: Icons.calendar_today,
                      label: t.convertFromGregorian,
                      onPressed: () => _openConversion(fromGregorian: true),
                    ),
                    const SizedBox(height: 12),
                    _animatedButton(
                      context: context,
                      icon: Icons.nightlight_round,
                      label: t.convertFromHijri,
                      onPressed: () => _openConversion(fromGregorian: false),
                    ),

                    const SizedBox(height: 20),

                    // بطاقة النتيجة
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeIn,
                      switchOutCurve: Curves.easeOut,
                      child: _lastResult == null
                          ? const SizedBox.shrink()
                          : DateResultCard(
                              key: ValueKey(_lastResult),
                              result: _lastResult!,
                            ),
                    ),

                    const SizedBox(height: 24),

                    // ✅ Banner Ad
                    if (_isBannerReady && _bannerAd != null)
                      SizedBox(
                        height: _bannerAd!.size.height.toDouble(),
                        width: _bannerAd!.size.width.toDouble(),
                        child: AdWidget(ad: _bannerAd!),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF4E7D5B),
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _bottomNavItem(
              icon: Icons.home,
              label: t.home,
              onTap: () {
                Feedback.forTap(context);
                setState(() {});
              },
            ),
            _bottomNavItem(
              icon: Icons.card_giftcard,
              label: t.moreButton,
              onTap: _showRewardedAd,
              showLoader: _isLoadingAd,
            ),
          ],
        ),
      ),
    );
  }

  /// ترجمة المناسبات (مقتطف)
  String _translateOccasion(String key, AppLocalizations t) {
    switch (key) {
      case "hijriNewYear":
        return t.hijriNewYear;
      // ... باقي المناسبات
    }
    return key;
  }

  /// زر أنيميشن + هتزاز
  Widget _animatedButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SlideTransition(
      position: _slideUp,
      child: FadeTransition(
        opacity: _fadeIn,
        child: ScaleTransition(
          scale: _scaleIn,
          child: GestureDetector(
            onTap: () {
              Feedback.forTap(context);
              onPressed();
            },
            child: GradientButton(
              icon: icon,
              label: label,
              onPressed: onPressed,
            ),
          ),
        ),
      ),
    );
  }

  /// عنصر Bottom Navigation
  Widget _bottomNavItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool showLoader = false,
  }) {
    return InkWell(
      onTap: () {
        Feedback.forTap(context);
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      splashColor: Colors.white24,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            showLoader
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(icon, color: Colors.white, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  final String weekday;
  final String gregTitle;
  final String gregText;
  final List<String> gregOccasions;
  final String hijriTitle;
  final String hijriText;
  final List<String> hijriOccasions;
  final String? showApproxNote;
  final TextTheme textTheme;

  const _TodayCard({
    required this.weekday,
    required this.gregTitle,
    required this.gregText,
    required this.gregOccasions,
    required this.hijriTitle,
    required this.hijriText,
    required this.hijriOccasions,
    this.showApproxNote,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: theme.colorScheme.surface.withValues(alpha: 0.95),
        shadowColor: theme.colorScheme.primary.withValues(alpha: 0.2),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                weekday,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 14),

              // Gregorian
              _LineTitle(
                icon: Icons.calendar_today_outlined,
                iconColor: Colors.blueAccent,
                text: gregTitle,
              ),
              const SizedBox(height: 6),
              Text(
                gregText,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              if (gregOccasions.isNotEmpty) ...[
                const SizedBox(height: 8),
                _OccasionList(items: gregOccasions, textTheme: textTheme),
              ],

              const SizedBox(height: 16),
              Divider(color: theme.dividerColor.withValues(alpha: .25)),
              const SizedBox(height: 12),

              // Hijri
              _LineTitle(
                icon: Icons.nightlight_round,
                iconColor: Colors.deepPurple,
                text: hijriTitle,
              ),
              const SizedBox(height: 6),
              Text(
                hijriText,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              if (hijriOccasions.isNotEmpty) ...[
                const SizedBox(height: 8),
                _OccasionList(items: hijriOccasions, textTheme: textTheme),
              ],

              if (showApproxNote != null) ...[
                const SizedBox(height: 12),
                Text(
                  showApproxNote!,
                  style: textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LineTitle extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;
  const _LineTitle(
      {required this.icon, required this.iconColor, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 8),
        Text(
          text,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

class _OccasionList extends StatelessWidget {
  final List<String> items;
  final TextTheme textTheme;
  const _OccasionList({required this.items, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: items
          .map(
            (o) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsetsDirectional.only(end: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      o,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
