import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// 🔹 Helper Class لإدارة كل أنواع الإعلانات
class AdHelper {
  // ✅ Banner Ad Unit ID
  static const String bannerAdUnitId = "ca-app-pub-9730483404299391/9271351671";

  // ✅ Interstitial Ad Unit ID
  static const String interstitialAdUnitId =
      "ca-app-pub-9730483404299391/4741897965";

  // ✅ Rewarded Interstitial Ad Unit ID
  static const String rewardedInterstitialAdUnitId =
      "ca-app-pub-9730483404299391/6864394776";

  // ✅ App Open Ad Unit ID
  static const String appOpenAdUnitId =
      "ca-app-pub-9730483404299391/4788895770";

  // ------------------------------
  // Banner Ad
  // ------------------------------
  static BannerAd createBannerAd({
    required VoidCallback onLoaded,
    VoidCallback? onFailed,
  }) {
    final ad = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint("✅ Banner Ad Loaded");
          onLoaded();
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint("❌ Banner Ad failed: $error");
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

  static void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          debugPrint("✅ Interstitial Ad Loaded");
        },
        onAdFailedToLoad: (error) {
          debugPrint("❌ Interstitial Ad failed: $error");
          _interstitialAd = null;
        },
      ),
    );
  }

  static void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
      loadInterstitialAd(); // لإعادة التحميل
    } else {
      debugPrint("⚠️ Interstitial Ad غير جاهز بعد");
    }
  }

  // ------------------------------
  // Rewarded Interstitial Ad
  // ------------------------------
  static RewardedInterstitialAd? _rewardedInterstitialAd;

  static void loadRewardedInterstitialAd() {
    RewardedInterstitialAd.load(
      adUnitId: rewardedInterstitialAdUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedInterstitialAd = ad;
          debugPrint("✅ Rewarded Interstitial Ad Loaded");
        },
        onAdFailedToLoad: (error) {
          debugPrint("❌ Rewarded Interstitial failed: $error");
          _rewardedInterstitialAd = null;
        },
      ),
    );
  }

  /// ✅ يدعم onFail إذا الإعلان مو جاهز
  static void showRewardedInterstitialAd(
    VoidCallback onRewardEarned, {
    VoidCallback? onFail,
  }) {
    if (_rewardedInterstitialAd != null) {
      _rewardedInterstitialAd!.show(
        onUserEarnedReward: (ad, reward) {
          debugPrint("🎁 User earned reward: ${reward.amount}");
          onRewardEarned();
        },
      );
      _rewardedInterstitialAd = null;
      loadRewardedInterstitialAd();
    } else {
      debugPrint("⚠️ Rewarded Interstitial Ad غير جاهز بعد");
      if (onFail != null) onFail();
    }
  }

  // ------------------------------
  // App Open Ad
  // ------------------------------
  static AppOpenAd? _appOpenAd;

  static void loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          debugPrint("✅ App Open Ad Loaded");
        },
        onAdFailedToLoad: (error) {
          debugPrint("❌ App Open Ad failed: $error");
          _appOpenAd = null;
        },
      ),
    );
  }

  static void showAppOpenAd() {
    if (_appOpenAd != null) {
      _appOpenAd!.show();
      _appOpenAd = null;
      loadAppOpenAd(); // لإعادة التحميل
    } else {
      // debugPrint("⚠️ App Open Ad غير جاهز بعد");
    }
  }
}
