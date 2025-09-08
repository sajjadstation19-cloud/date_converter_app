import 'dart:async'; // ✅ مهم للمؤقت
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // ✅ Banner Ad
  BannerAd? _bannerAd;
  bool _isBannerReady = false;

  // ✅ Interstitial Ad counter
  int _conversionCount = 0;

  // ✅ انتظار إعلان المزيد
  bool _isLoadingAd = false;
  bool _cancelLoading = false;
  Timer? _retryTimer;
  int _retryCount = 0;

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
    _bannerAd?.dispose();
    _retryTimer?.cancel(); // ✅ تنظيف المؤقت
    super.dispose();
  }

  /// إعلان مكافأة (إجباري عند الضغط على زر المزيد)
  void _showRewardedAd() {
    HapticFeedback.lightImpact();
    setState(() {
      _isLoadingAd = true;
      _cancelLoading = false;
      _retryCount = 0;
    });

    void tryShowAd() {
      if (!mounted || _cancelLoading) return;
      if (AdHelper.hasRewardedAd) {
        _retryTimer?.cancel();
        AdHelper.showRewardedInterstitialAd(() {
          if (!mounted) return;
          setState(() => _isLoadingAd = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("🎬 ${AppLocalizations.of(context).watchAdReward}"),
              behavior: SnackBarBehavior.floating,
            ),
          );
          AdHelper.loadRewardedInterstitialAd();
        }, onFail: () {
          if (!mounted) return;
          setState(() => _isLoadingAd = false);
          AdHelper.loadRewardedInterstitialAd();
        });
      }
    }

    // محاولة أولية
    tryShowAd();

    // إذا ماكو إعلان → إعادة المحاولة كل ثانيتين بحد أقصى 15 ثانية
    _retryTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_cancelLoading || _retryCount >= 7) {
        timer.cancel();
        if (mounted) setState(() => _isLoadingAd = false);
        return;
      }
      _retryCount++;
      tryShowAd();
    });
  }

  Future<void> _openConversion({required bool fromGregorian}) async {
    HapticFeedback.lightImpact();
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

    return PopScope(
      canPop: !_isLoadingAd,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isLoadingAd) {
          setState(() {
            _isLoadingAd = false;
            _cancelLoading = true;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF4E7D5B),
          centerTitle: true,
          leading: _buildAppBarButton(
            icon: Icons.settings,
            tooltip: t.settings,
            onPressed: () {
              HapticFeedback.lightImpact();
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
            _buildAppBarButton(
              icon: Icons.calendar_month,
              tooltip: t.todayWord,
              onPressed: () => HapticFeedback.lightImpact(),
            ),
          ],
        ),
        body: GestureDetector(
          onTap: () {
            if (_isLoadingAd) {
              setState(() {
                _isLoadingAd = false;
                _cancelLoading = true;
              });
            }
          },
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
                        const SizedBox(height: 24),
                        _buildActionButton(
                          icon: Icons.calendar_today,
                          label: t.convertFromGregorian,
                          onPressed: () => _openConversion(fromGregorian: true),
                        ),
                        const SizedBox(height: 12),
                        _buildActionButton(
                          icon: Icons.nightlight_round,
                          label: t.convertFromHijri,
                          onPressed: () =>
                              _openConversion(fromGregorian: false),
                        ),
                        const SizedBox(height: 20),
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
        ),
        bottomNavigationBar: BottomAppBar(
          color: const Color(0xFF4E7D5B),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavButton(
                icon: Icons.home,
                label: t.home,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {});
                },
              ),
              _buildNavButton(
                icon: Icons.card_giftcard,
                label: t.moreButton,
                onPressed: _isLoadingAd ? () {} : _showRewardedAd,
                isLoading: _isLoadingAd,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 زر موحد للـ AppBar
  Widget _buildAppBarButton(
      {required IconData icon,
      required String tooltip,
      required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Material(
        color: Colors.white.withOpacity(0.15),
        shape: const CircleBorder(),
        child: IconButton(
          icon: Icon(icon, color: Colors.white),
          tooltip: tooltip,
          onPressed: onPressed,
        ),
      ),
    );
  }

  /// 🔹 زر موحد لأزرار التحويل
  Widget _buildActionButton(
      {required IconData icon,
      required String label,
      required VoidCallback onPressed}) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF4E7D5B),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(fontSize: 16),
      ),
    );
  }

  /// 🔹 زر موحد للـ BottomAppBar
  Widget _buildNavButton(
      {required IconData icon,
      required String label,
      required VoidCallback onPressed,
      bool isLoading = false}) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              const SizedBox(height: 16),
              Divider(color: theme.dividerColor.withValues(alpha: .25)),
              const SizedBox(height: 12),
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
