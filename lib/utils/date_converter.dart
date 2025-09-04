// ignore_for_file: avoid_classes_with_only_static_members

import 'package:hijri/hijri_calendar.dart';
import 'package:jhijri/jhijri.dart' as jh;

import '../models/conversion_output.dart';
import 'date_utils.dart';

/// محوّل التاريخ مع تفضيل أمّ القرى قدر الإمكان.
/// - ميلادي → هجري: نحاول أمّ القرى عبر jhijri، ونرجع fallback للهجري عند الفشل.
/// - هجري → ميلادي: نستخدم hijri_calendar عبر hijriToGregorian (المتاح في الباكدج)،
///   ونعتبرها تقريبية إذا التاريخ خارج نطاق أمّ القرى.
class DateConverter {
  // نطاق تقريبي لتواريخ أمّ القرى (هجري): 1318هـ → 1500هـ
  static const int _minAH = 1318;
  static const int _maxAH = 1500;

  static bool _isInUmmAlQuraRange(int hYear) =>
      hYear >= _minAH && hYear <= _maxAH;

  /// ميلادي → هجري
  static ConversionOutput convertGregorianToHijri(DateTime g) {
    try {
      // أمّ القرى (jhijri)
      final j = jh.HijriDate.dateToHijri(g);
      final approx = !_isInUmmAlQuraRange(j.year);

      final h = HijriCalendar()
        ..hYear = j.year
        ..hMonth = j.month
        ..hDay = j.day;

      return ConversionOutput(
        gregorian: g,
        hijri: h,
        weekdayAr: DateUtilsX.weekdayNameAr(g.weekday),
        approximate: approx,
      );
    } catch (_) {
      // fallback: hijri_calendar
      final h = HijriCalendar.fromDate(g);
      return ConversionOutput(
        gregorian: g,
        hijri: h,
        weekdayAr: DateUtilsX.weekdayNameAr(g.weekday),
        approximate: true,
      );
    }
  }

  /// هجري → ميلادي
  static ConversionOutput convertHijriToGregorian({
    required int hYear,
    required int hMonth,
    required int hDay,
  }) {
    // التحويل الصحيح في باكدج hijri يكون عبر hijriToGregorian
    final g = HijriCalendar().hijriToGregorian(hYear, hMonth, hDay);
    final approx = !_isInUmmAlQuraRange(hYear);

    // نرجّع نفس التاريخ الهجري المدخل ككائن HijriCalendar للعرض
    final hOut = HijriCalendar()
      ..hYear = hYear
      ..hMonth = hMonth
      ..hDay = hDay;

    return ConversionOutput(
      gregorian: g,
      hijri: hOut,
      weekdayAr: DateUtilsX.weekdayNameAr(g.weekday),
      approximate: approx,
    );
  }
}
