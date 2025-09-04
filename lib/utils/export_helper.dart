import 'dart:convert';
import 'package:share_plus/share_plus.dart';

import '../models/conversion_output.dart';
import 'date_utils.dart';

class ExportHelper {
  ExportHelper._();

  /// يبني نصًا للعرض أو المشاركة (تستخدم في واجهة المستخدم القديمة)
  static String buildText({
    required ConversionOutput result,
    String? occasion,
    required String weekdayLabel,
    required String hijriLabel,
    required String gregorianLabel,
    String? approximateNote,
  }) {
    final gStr = DateUtilsHelper.formatGregorian(result.gregorian);
    final hStr = DateUtilsHelper.formatHijri(result.hijri);
    final buf = StringBuffer()
      ..writeln('$weekdayLabel: ${result.weekdayAr}')
      ..writeln('$hijriLabel: $hStr')
      ..writeln('$gregorianLabel: $gStr');
    if ((occasion ?? '').trim().isNotEmpty) {
      buf.writeln();
      buf.writeln('— $occasion —');
    }
    if (result.approximate && (approximateNote ?? '').isNotEmpty) {
      buf.writeln();
      buf.writeln(approximateNote);
    }
    return buf.toString().trimRight();
  }

  /// إنشاء نص للتصدير (تنسيق نصي)
  static String toTxt(ConversionOutput result, {String? occasion}) {
    final lines = <String>[
      'Gregorian: ${DateUtilsHelper.formatGregorian(result.gregorian)}',
      'Hijri    : ${DateUtilsHelper.formatHijri(result.hijri)}',
      if (occasion != null && occasion.isNotEmpty) 'Occasion : $occasion',
      if (result.approximate)
        'Note     : Approximate (outside Umm Al-Qura range)',
    ];
    return lines.join('\n');
  }

  /// إنشاء نص للتصدير (تنسيق JSON)
  static String toJson(ConversionOutput result, {String? occasion}) {
    final map = {
      'gregorian': DateUtilsHelper.formatGregorian(result.gregorian),
      'hijri': DateUtilsHelper.formatHijri(result.hijri),
      if (occasion != null && occasion.isNotEmpty) 'occasion': occasion,
      if (result.approximate) 'note': 'Approximate (outside Umm Al-Qura range)',
    };
    return jsonEncode(map);
  }

  /// مشاركة نص عبر share_plus
  static Future shareText(String text) async {
    // Use the new SharePlus API instead of the deprecated Share.share().
    final params = ShareParams(text: text);
    await SharePlus.instance.share(params);
  }
}
