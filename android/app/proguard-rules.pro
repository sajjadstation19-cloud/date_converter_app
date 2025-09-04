# -----------------------------
# ✅ Flutter
# -----------------------------
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# -----------------------------
# ✅ Google Mobile Ads
# -----------------------------
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# ✅ لا تحذف MainActivity حتى مع الـ shrink
-keep class com.dbs.dateconverter.MainActivity { *; }


# -----------------------------
# ✅ Google Play Core (حل مشكلة SplitCompat / Deferred Components)
# -----------------------------
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# -----------------------------
# ✅ Prevent Warnings
# -----------------------------
-dontwarn javax.annotation.**
-dontwarn org.codehaus.mojo.**