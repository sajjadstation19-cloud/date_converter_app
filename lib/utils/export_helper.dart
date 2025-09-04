import 'package:share_plus/share_plus.dart';

import '../models/conversion_output.dart';
import 'date_utils.dart';

class ExportHelper {
  ExportHelper._();

  /// يبني نصًا قابلاً للنسخ/المشاركة
  static String buildText({
    required ConversionOutput result,
    String? occasion,
    required String weekdayLabel, // مثال: "اليوم"
    required String hijriLabel, // مثال: "هجري"
    required String gregorianLabel, // مثال: "ميلادي"
    String? approximateNote, // مثال: "⚠️ بعض التواريخ تقريبية"
  }) {
    final g = result.gregorian;
    final h = result.hijri;

    final gStr = DateUtilsHelper.formatGregorian(g);
    final hStr = DateUtilsHelper.formatHijri(h);

    final buf = StringBuffer()
      ..writeln('$weekdayLabel: ${result.weekdayAr}')
      ..writeln('$hijriLabel: $hStr')
      ..writeln('$gregorianLabel: $gStr');

    if ((occasion ?? '').trim().isNotEmpty) {
      buf.writeln();
      buf.writeln('— $occasion —');
    }

    if (result.approximate == true && (approximateNote ?? '').isNotEmpty) {
      buf.writeln();
      buf.writeln(approximateNote);
    }

    return buf.toString().trimRight();
  }

  /// مشاركة نص مباشر عبر share_plus
  static Future<void> shareText(String text) async {
    await Share.share(text);
  }
}
