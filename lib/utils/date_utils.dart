import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';

/// حزمة قيم جاهزة لتاريخ اليوم (ميلادي + هجري) مع أسماء الأيام
class TodayDates {
  final DateTime gregorian;
  final HijriCalendar hijri;
  final String weekdayAr;
  final String weekdayEn;
  final bool approximate;

  TodayDates({
    required this.gregorian,
    required this.hijri,
    required this.weekdayAr,
    required this.weekdayEn,
    this.approximate = false,
  });
}

/// أدوات مساعدة للتواريخ + حسابات بسيطة
class DateUtilsX {
  DateUtilsX._();

  /// أيام الأسبوع بالعربي
  static const List<String> weekdaysAr = [
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  /// أيام الأسبوع بالإنكليزي
  static const List<String> weekdaysEn = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  /// أشهر ميلادية بالعربي
  static const List<String> gregorianMonthsAr = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  /// أشهر ميلادية بالإنكليزي (ثابتة بدل الاعتماد فقط على intl)
  static const List<String> gregorianMonthsEn = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  /// أشهر هجرية بالعربي
  static const List<String> hijriMonthsAr = [
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الآخر',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة',
  ];

  /// تاريخ اليوم جاهز
  static TodayDates getToday() {
    final now = DateTime.now();
    final hijri = HijriCalendar.fromDate(now);
    return TodayDates(
      gregorian: now,
      hijri: hijri,
      weekdayAr: weekdaysAr[now.weekday - 1],
      weekdayEn: weekdaysEn[now.weekday - 1],
      approximate: false,
    );
  }

  /// اسم اليوم بالعربي من رقم weekday (1=Mon .. 7=Sun)
  static String weekdayNameAr(int weekday) {
    return weekdaysAr[weekday - 1];
  }

  /// اسم اليوم بالإنكليزي من رقم weekday (1=Mon .. 7=Sun)
  static String weekdayNameEn(int weekday) {
    return weekdaysEn[weekday - 1];
  }

  /// تنسيق ميلادي: 2025 (سبتمبر 1) أو 2025 (September 1)
  static String formatGregorianYMD(DateTime date) {
    final locale = Intl.getCurrentLocale();
    final isAr = locale.toLowerCase().startsWith('ar');
    final mName = isAr
        ? gregorianMonthsAr[date.month - 1]
        : gregorianMonthsEn[date.month - 1];
    return '${date.year} ($mName ${date.day})';
  }

  /// تنسيق هجري: 1447 هـ (ربيع الأول 9)
  static String formatHijriYMD(HijriCalendar h) {
    final mName = hijriMonthsAr[h.hMonth - 1];
    return '${h.hYear} هـ ($mName ${h.hDay})';
  }

  /// عدد أيام الشهر الميلادي
  static int gregorianMonthLength(int year, int month) {
    final nextMonth = month == 12 ? 1 : month + 1;
    final nextYear = month == 12 ? year + 1 : year;
    return DateTime(nextYear, nextMonth, 0).day;
  }

  /// عدد أيام الشهر الهجري بالتحقق عبر محاولة التحويل (آمن)
  static int hijriMonthLength(int hYear, int hMonth) {
    for (var d = 30; d >= 29; d--) {
      try {
        HijriCalendar().hijriToGregorian(hYear, hMonth, d);
        return d;
      } catch (_) {}
    }
    return 29;
  }

  /// تحويل هجري → ميلادي
  static DateTime hijriToGregorian(int hYear, int hMonth, int hDay) {
    return HijriCalendar().hijriToGregorian(hYear, hMonth, hDay);
  }

  /// تحويل ميلادي → هجري
  static HijriCalendar gregorianToHijri(DateTime g) {
    return HijriCalendar.fromDate(g);
  }
}

/// كلاس مساعد كما يتوقعه باقي الكود
class DateUtilsHelper {
  DateUtilsHelper._();

  /// ميلادي: 2025 (سبتمبر 1) أو 2025 (September 1)
  static String formatGregorian(DateTime date) {
    final locale = Intl.getCurrentLocale();
    final isAr = locale.toLowerCase().startsWith('ar');
    final mName = isAr
        ? DateUtilsX.gregorianMonthsAr[date.month - 1]
        : DateUtilsX.gregorianMonthsEn[date.month - 1];
    return '${date.year} ($mName ${date.day})';
  }

  /// تحويل ميلادي → هجري
  static HijriCalendar toHijri(DateTime gregorian) {
    return HijriCalendar.fromDate(gregorian);
  }

  /// هجري: 1447 هـ (ربيع الأول 9)
  static String formatHijri(HijriCalendar h) {
    final name = DateUtilsX.hijriMonthsAr[h.hMonth - 1];
    return '${h.hYear} هـ ($name ${h.hDay})';
  }

  /// (اختياري) اسم شهر عام (هجري/ميلادي)
  static String getMonthName(int month,
      {bool hijri = false, bool isAr = true}) {
    final idx = (month - 1).clamp(0, 11);
    if (hijri) return DateUtilsX.hijriMonthsAr[idx];
    return isAr
        ? DateUtilsX.gregorianMonthsAr[idx]
        : DateUtilsX.gregorianMonthsEn[idx];
  }
}
