import 'package:flutter/material.dart';
import 'package:date_converter_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:flutter/services.dart';

import '../utils/date_utils.dart';
import '../utils/date_converter.dart';
import '../models/conversion_output.dart';

class ConversionBottomSheet extends StatefulWidget {
  /// true: تحويل من ميلادي → هجري
  /// false: تحويل من هجري → ميلادي
  final bool fromGregorian;

  const ConversionBottomSheet({super.key, required this.fromGregorian});

  @override
  State<ConversionBottomSheet> createState() => _ConversionBottomSheetState();
}

class _ConversionBottomSheetState extends State<ConversionBottomSheet> {
  int? selectedDay;
  int? selectedMonth;
  int? selectedYear;
  List<int> _days = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    if (widget.fromGregorian) {
      selectedDay = now.day;
      selectedMonth = now.month;
      selectedYear = now.year;
    } else {
      final h = HijriCalendar.fromDate(now);
      selectedDay = h.hDay;
      selectedMonth = h.hMonth;
      selectedYear = h.hYear;
    }
    _rebuildDays();
  }

  // أسماء الأشهر
  String _gregorianMonthLabel(BuildContext context, int m) {
    final lang = Localizations.localeOf(context).languageCode;
    if (lang == 'ar') {
      return DateUtilsX.gregorianMonthsAr[m - 1];
    }
    return DateFormat.MMMM('en').format(DateTime(2000, m, 1));
  }

  String _hijriMonthLabel(BuildContext context, int m) {
    final lang = Localizations.localeOf(context).languageCode;
    return lang == 'ar'
        ? DateUtilsX.hijriMonthsAr[m - 1]
        : DateUtilsX.hijriMonthsEn[m - 1];
  }

  String _monthLabel(BuildContext context, int m) {
    final name = widget.fromGregorian
        ? _gregorianMonthLabel(context, m)
        : _hijriMonthLabel(context, m);
    return '$m – $name';
  }

  // إعادة بناء الأيام
  void _rebuildDays() {
    if (selectedMonth == null || selectedYear == null) {
      _days = List.generate(31, (i) => i + 1);
      setState(() {});
      return;
    }

    if (widget.fromGregorian) {
      final len = DateUtilsX.gregorianMonthLength(
        selectedYear!,
        selectedMonth!,
      );
      _days = List.generate(len, (i) => i + 1);
      if (selectedDay != null && selectedDay! > len) selectedDay = len;
    } else {
      final len = DateUtilsX.hijriMonthLength(selectedYear!, selectedMonth!);
      _days = List.generate(len, (i) => i + 1);
      if (selectedDay != null && selectedDay! > len) selectedDay = len;
    }

    setState(() {});
  }

  // التحويل
  void _handleConvert() {
    final t = AppLocalizations.of(context);
    HapticFeedback.selectionClick();

    if (selectedDay == null || selectedMonth == null || selectedYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.selectAllFields),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      late DateTime greg;
      late HijriCalendar hij;
      bool approximate = false;

      if (widget.fromGregorian) {
        final g = DateTime(selectedYear!, selectedMonth!, selectedDay!);
        final res = DateConverter.convertGregorianToHijri(g);
        greg = res.gregorian;
        hij = res.hijri;
        approximate = res.approximate;
      } else {
        final res = DateConverter.convertHijriToGregorian(
          hYear: selectedYear!,
          hMonth: selectedMonth!,
          hDay: selectedDay!,
        );
        greg = res.gregorian;
        hij = res.hijri;
        approximate = res.approximate;
      }

      final weekdayAr = DateUtilsX.weekdayArOf(greg);

      HapticFeedback.lightImpact();
      Navigator.of(context).pop(
        ConversionOutput(
          gregorian: greg,
          hijri: hij,
          weekdayAr: weekdayAr,
          approximate: approximate,
        ),
      );
    } catch (e) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.noteAccuracy),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Widgets للقوائم
  Widget _yearDropdown(AppLocalizations t) {
    final years = widget.fromGregorian
        ? List<int>.generate(201, (i) => 1900 + i)
        : List<int>.generate(301, (i) => 1300 + i);

    return DropdownButtonFormField<int>(
      initialValue: selectedYear,
      decoration: InputDecoration(labelText: t.year),
      isExpanded: true,
      items: years
          .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
          .toList(),
      onChanged: (v) {
        if (v == null) return;
        selectedYear = v;
        _rebuildDays();
      },
    );
  }

  Widget _monthDropdown(AppLocalizations t) {
    final months = List<int>.generate(12, (i) => i + 1);

    return DropdownButtonFormField<int>(
      initialValue: selectedMonth,
      decoration: InputDecoration(labelText: t.month),
      isExpanded: true,
      items: months
          .map(
            (m) => DropdownMenuItem<int>(
              value: m,
              child: Text(_monthLabel(context, m)),
            ),
          )
          .toList(),
      onChanged: (v) {
        if (v == null) return;
        selectedMonth = v;
        _rebuildDays();
      },
    );
  }

  Widget _dayDropdown(AppLocalizations t) {
    return DropdownButtonFormField<int>(
      initialValue: selectedDay,
      decoration: InputDecoration(labelText: t.day),
      isExpanded: true,
      items: _days
          .map((d) => DropdownMenuItem(value: d, child: Text('$d')))
          .toList(),
      onChanged: (v) {
        if (v == null) return;
        setState(() => selectedDay = v);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: .4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.fromGregorian
                        ? t.convertFromGregorian
                        : t.convertFromHijri,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: t.close,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Divider(
                  color: Theme.of(context).dividerColor.withValues(alpha: .35)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _dayDropdown(t)),
                  const SizedBox(width: 8),
                  Expanded(child: _monthDropdown(t)),
                  const SizedBox(width: 8),
                  Expanded(child: _yearDropdown(t)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(t.convert),
                  onPressed: () {
                    Feedback.forTap(context);
                    _handleConvert();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
