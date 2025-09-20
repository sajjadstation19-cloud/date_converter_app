import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// 🔹 Helper Class لإدارة الإعلانات (Banner, Interstitial, Rewarded, App Open)
class AdHelper {
  // ✅ IDs الحقيقية من حسابك
  static const String interstitialAdUnitId =
      "ca-app-pub-9730483404299391/1297192530"; // إعلان بيني
  static const String rewardedInterstitialAdUnitId =
      "ca-app-pub-9730483404299391/3017468317"; // إعلان بيني مكافأة
  static const String bannerAdUnitId =
      "ca-app-pub-9730483404299391/5970934712"; // إعلان بانر
  static const String appOpenAdUnitId =
      "ca-app-pub-9730483404299391/7818422750"; // إعلان فتح التطبيق

  /// 🕒 أداة طباعة مع التوقيت
  static void _log(String message) {
    final now = DateTime.now();
    final time =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
    debugPrint("[Ad][$time] $message");
  }

  // ------------------------------
  // Banner Ad
  // ------------------------------
  static bool isBannerReady = false;
  static BannerAd createBannerAd({
    required VoidCallback onLoaded,
    VoidCallback? onFailed,
  }) {
    _log("📥 Requesting Banner Ad...");
    final ad = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          isBannerReady = true;
          _log("✅ Banner Ad Loaded & Ready");
          onLoaded();
        },
        onAdFailedToLoad: (ad, error) {
          isBannerReady = false;
          _log("❌ Banner Ad failed: ${error.code} | ${error.message}");
          ad.dispose();
          if (onFailed != null) onFailed();
        },
      ),
    );
    ad.load();
    return ad;
  }

  // ------------------------------
  // Interstitial Ad
  // ------------------------------
  static InterstitialAd? _interstitialAd;
  static bool get hasInterstitial => _interstitialAd != null;

  static void loadInterstitialAd() {
    _log("📥 Requesting Interstitial Ad...");
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _log("✅ Interstitial Ad Loaded & Ready");
        },
        onAdFailedToLoad: (error) {
          _log("❌ Interstitial Ad failed: ${error.code} | ${error.message}");
          _interstitialAd = null;
        },
      ),
    );
  }

  static void showInterstitialAd() {
    if (_interstitialAd != null) {
      _log("📺 Showing Interstitial Ad...");
      _interstitialAd!.show();
      _interstitialAd = null;
      loadInterstitialAd(); // إعادة التحميل مباشرة
    } else {
      _log("⚠️ Interstitial Ad غير جاهز بعد");
    }
  }

  // ------------------------------
  // Rewarded Interstitial Ad
  // ------------------------------
  static RewardedInterstitialAd? _rewardedInterstitialAd;
  static bool get hasRewardedAd => _rewardedInterstitialAd != null;

  static void loadRewardedInterstitialAd({VoidCallback? onLoaded}) {
    _log("📥 Requesting Rewarded Interstitial Ad...");
    RewardedInterstitialAd.load(
      adUnitId: rewardedInterstitialAdUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedInterstitialAd = ad;
          _log("✅ Rewarded Interstitial Ad Loaded & Ready");
          onLoaded?.call();
        },
        onAdFailedToLoad: (error) {
          _log(
              "❌ Rewarded Interstitial failed: ${error.code} | ${error.message}");
          _rewardedInterstitialAd = null;
        },
      ),
    );
  }

  static void showRewardedInterstitialAd(
    VoidCallback onRewardEarned, {
    VoidCallback? onFail,
  }) {
    if (_rewardedInterstitialAd != null) {
      _log("📺 Showing Rewarded Interstitial Ad...");
      _rewardedInterstitialAd!.fullScreenContentCallback =
          FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          _log("ℹ️ Rewarded Ad dismissed");
          ad.dispose();
          _rewardedInterstitialAd = null;
          loadRewardedInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          _log(
              "❌ Rewarded Ad failed to show: ${error.code} | ${error.message}");
          ad.dispose();
          _rewardedInterstitialAd = null;
          onFail?.call();
          loadRewardedInterstitialAd();
        },
      );
      _rewardedInterstitialAd!.show(
        onUserEarnedReward: (ad, reward) {
          _log("🎁 User earned reward: ${reward.amount} ${reward.type}");
          onRewardEarned();
        },
      );
      _rewardedInterstitialAd = null;
    } else {
      _log("⚠️ Rewarded Interstitial Ad غير جاهز بعد");
      if (onFail != null) onFail();
    }
  }

  // ------------------------------
  // App Open Ad
  // ------------------------------
  static AppOpenAd? _appOpenAd;
  static bool get hasAppOpen => _appOpenAd != null;

  static void loadAppOpenAd() {
    _log("📥 Requesting App Open Ad...");
    AppOpenAd.load(
      adUnitId: appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _log("✅ App Open Ad Loaded & Ready");
        },
        onAdFailedToLoad: (error) {
          _log("❌ App Open Ad failed: ${error.code} | ${error.message}");
          _appOpenAd = null;
        },
      ),
    );
  }

  static void showAppOpenAd() {
    if (_appOpenAd != null) {
      _log("📺 Showing App Open Ad...");
      _appOpenAd!.show();
      _appOpenAd = null;
      loadAppOpenAd();
    } else {
      _log("⚠️ App Open Ad غير جاهز بعد");
    }
  }

  // ------------------------------
  // ✅ Preload All Ads
  // ------------------------------
  static void preloadAllAds() {
    _log("🚀 Preloading all ads...");
    loadInterstitialAd();
    loadRewardedInterstitialAd();
    loadAppOpenAd();
  }
}
