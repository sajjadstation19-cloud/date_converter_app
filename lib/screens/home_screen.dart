import 'dart:async'; // ✅ مهم للمؤقت
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // ✅ Ads
import 'package:date_converter_app/l10n/app_localizations.dart';
import '../widgets/conversion_bottom_sheet.dart';
import '../widgets/date_result_card.dart';
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

  // ✅ Banner Ads
  BannerAd? _bannerAdTop;
  BannerAd? _bannerAdBottom;
  bool _isBannerTopReady = false;
  bool _isBannerBottomReady = false;

  // ✅ Interstitial Ad counter
  int _conversionCount = 0;

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

    // ✅ تحميل إعلان بانر علوي
    _bannerAdTop = AdHelper.createBannerAd(
      onLoaded: () {
        setState(() => _isBannerTopReady = true);
      },
    );

    // ✅ تحميل إعلان بانر سفلي
    _bannerAdBottom = AdHelper.createBannerAd(
      onLoaded: () {
        setState(() => _isBannerBottomReady = true);
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
    _bannerAdTop?.dispose();
    _bannerAdBottom?.dispose();
    super.dispose();
  }

  /// ✅ نافذة التحويل مع Animation سلس + Material
  Future<void> _openConversion({required bool fromGregorian}) async {
    final result = await Navigator.of(context).push(
      PageRouteBuilder<ConversionOutput>(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black54,
        pageBuilder: (context, _, __) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: 0.75, // 🔹 قللنا الارتفاع لتخفيف الفراغ
              child: Material(
                color: Colors.transparent,
                child: ConversionBottomSheet(fromGregorian: fromGregorian),
              ),
            ),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final slideTween = Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic));
          final fadeTween = Tween<double>(begin: 0, end: 1);
          return SlideTransition(
            position: animation.drive(slideTween),
            child: FadeTransition(
              opacity: animation.drive(fadeTween),
              child: child,
            ),
          );
        },
      ),
    );

    if (!mounted) return;
    if (result != null) {
      setState(() {
        _lastResult = result;
        _conversionCount++;
      });
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
    final today = DateUtilsX.getToday();
    final isAr = Localizations.localeOf(context).languageCode == "ar";

    final g = today.gregorian;
    final gMonthName = DateUtilsHelper.getMonthName(g.month, isAr: isAr);
    final gregText = '${g.year} ($gMonthName ${g.day})';

    final h = today.hijri;
    final hMonthName = isAr
        ? DateUtilsX.hijriMonthsAr[h.hMonth - 1]
        : DateUtilsX.hijriMonthsEn[h.hMonth - 1];
    final hijriText = '${h.hYear} هـ ($hMonthName ${h.hDay})';

    final hijriKey = getHijriOccasionKey(today.hijri);
    final gregKeys = getGregorianOccasionKeys(today.gregorian);

    final hijriOccasions = <String>[
      if (hijriKey != null) _translateOccasion(hijriKey, t),
    ];
    final gregorianOccasions =
        gregKeys.map((k) => _translateOccasion(k, t)).toList();

    final weekday = isAr
        ? DateUtilsX.weekdayArOf(today.gregorian)
        : DateUtilsX.weekdayEnOf(today.gregorian);

    const mainColor = Color(0xFF3E6649); // ✅ أخضر زيتوني أدكن

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          tooltip: t.settings,
          onPressed: () {
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
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.white),
            tooltip: t.todayWord,
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔼 بانر علوي
          if (_isBannerTopReady && _bannerAdTop != null)
            SizedBox(
              height: _bannerAdTop!.size.height.toDouble(),
              width: _bannerAdTop!.size.width.toDouble(),
              child: AdWidget(ad: _bannerAdTop!),
            ),
          // 🔹 محتوى الصفحة
          Expanded(
            child: Container(
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF121212)
                  : const Color(0xFFE9F3EB),
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
                                  hijriTitle:
                                      "${t.todayHijriTitle} ${t.todayWord}",
                                  hijriText: hijriText,
                                  hijriOccasions: hijriOccasions,
                                  showApproxNote:
                                      today.approximate ? t.noteAccuracy : null,
                                  textTheme: textTheme,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16), // 🔹 قللنا الفراغ
                          _buildActionButton(
                            icon: Icons.calendar_today,
                            label: t.convertFromGregorian,
                            onPressed: () =>
                                _openConversion(fromGregorian: true),
                            color: mainColor,
                          ),
                          const SizedBox(height: 10),
                          _buildActionButton(
                            icon: Icons.nightlight_round,
                            label: t.convertFromHijri,
                            onPressed: () =>
                                _openConversion(fromGregorian: false),
                            color: mainColor,
                          ),
                          const SizedBox(height: 16),
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // 🔽 بانر سفلي ثابت
          SizedBox(
            height: _bannerAdBottom?.size.height.toDouble() ?? 50,
            width: _bannerAdBottom?.size.width.toDouble() ?? double.infinity,
            child: _isBannerBottomReady && _bannerAdBottom != null
                ? AdWidget(ad: _bannerAdBottom!)
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  /// 🔹 زر موحد لأزرار التحويل (Ripple طبيعي)
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(fontSize: 16),
        elevation: 3,
      ),
    );
  }

  String _translateOccasion(String key, AppLocalizations t) {
    switch (key) {
      case "hijriNewYear":
        return t.hijriNewYear;
    }
    return key;
  }
}

// باقي الكلاسات مثل ما هي 👇
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
              const SizedBox(height: 12),
              Divider(color: theme.dividerColor.withValues(alpha: .25)),
              const SizedBox(height: 10),
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
                const SizedBox(height: 10),
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
