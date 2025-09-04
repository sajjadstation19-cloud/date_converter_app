import 'package:hijri/hijri_calendar.dart';

class ConversionOutput {
  final DateTime gregorian;
  final HijriCalendar hijri;
  final String weekdayAr;
  final bool approximate;

  const ConversionOutput({
    required this.gregorian,
    required this.hijri,
    required this.weekdayAr,
    this.approximate = false,
  });
}
