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

  static const List<String> _weekdaysAr = [
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  static const List<String> _weekdaysEn = [
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
      weekdayAr: weekdayArOf(now),
      weekdayEn: weekdayEnOf(now),
      approximate: false,
    );
  }

  /// اسم اليوم بالعربي من DateTime
  static String weekdayArOf(DateTime date) => _weekdaysAr[date.weekday - 1];

  /// اسم اليوم بالإنجليزي من DateTime
  static String weekdayEnOf(DateTime date) => _weekdaysEn[date.weekday - 1];

  /// اسم اليوم بالعربي من رقم weekday (1=Mon .. 7=Sun)
  static String weekdayNameAr(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'الاثنين';
      case DateTime.tuesday:
        return 'الثلاثاء';
      case DateTime.wednesday:
        return 'الأربعاء';
      case DateTime.thursday:
        return 'الخميس';
      case DateTime.friday:
        return 'الجمعة';
      case DateTime.saturday:
        return 'السبت';
      case DateTime.sunday:
      default:
        return 'الأحد';
    }
  }

  /// تنسيق ميلادي: 2025 (سبتمبر 1)
  static String formatGregorianYMD(DateTime date) {
    final locale = Intl.getCurrentLocale();
    final isAr = locale.toLowerCase().startsWith('ar');
    final mName = isAr
        ? gregorianMonthsAr[date.month - 1]
        : DateFormat.MMMM(locale).format(date);
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

  /// ميلادي: 2025 (سبتمبر 1)
  static String formatGregorian(DateTime date) {
    final locale = Intl.getCurrentLocale();
    final isAr = locale.toLowerCase().startsWith('ar');
    final mName = isAr
        ? DateUtilsX.gregorianMonthsAr[date.month - 1]
        : DateFormat.MMMM(locale).format(date);
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
  static String getMonthName(int month, {bool hijri = false}) {
    final idx = (month - 1).clamp(0, 11);
    return hijri
        ? DateUtilsX.hijriMonthsAr[idx]
        : DateUtilsX.gregorianMonthsAr[idx];
  }
}
