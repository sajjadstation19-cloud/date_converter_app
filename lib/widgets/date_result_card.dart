import 'package:date_converter_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/conversion_output.dart';
import '../utils/date_utils.dart';
import '../utils/export_helper.dart';

class DateResultCard extends StatefulWidget {
  final ConversionOutput result;

  const DateResultCard({super.key, required this.result});

  @override
  State<DateResultCard> createState() => _DateResultCardState();
}

class _DateResultCardState extends State<DateResultCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;
  late final Animation<double> _scaleIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, .1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _scaleIn = Tween<double>(
      begin: .98,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    final hijriStr = DateUtilsHelper.formatHijri(widget.result.hijri);
    final gregStr = DateUtilsHelper.formatGregorian(widget.result.gregorian);

    final shareText = ExportHelper.buildText(
      result: widget.result,
      occasion: null, // 🚫 لا مناسبات
      weekdayLabel: t.resultWeekday,
      hijriLabel: t.resultHijri,
      gregorianLabel: t.resultGregorian,
      approximateNote: widget.result.approximate ? t.noteAccuracy : null,
    );

    return SlideTransition(
      position: _slideUp,
      child: FadeTransition(
        opacity: _fadeIn,
        child: ScaleTransition(
          scale: _scaleIn,
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 📌 العنوان
                  Text(
                    "📌 ${t.resultTitle}", // أضف "resultTitle": "نتيجة التحويل" في ملفات arb
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 10),

                  _rowItem(context, t.resultWeekday, widget.result.weekdayAr),
                  const SizedBox(height: 6),
                  _rowItem(context, t.resultHijri, hijriStr),
                  const SizedBox(height: 6),
                  _rowItem(context, t.resultGregorian, gregStr),

                  if (widget.result.approximate) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 18,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            t.noteAccuracy,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _actionBtn(
                        context,
                        icon: Icons.copy_rounded,
                        label: t.copy,
                        onTap: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          await Clipboard.setData(
                              ClipboardData(text: shareText));
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(t.copy),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      _actionBtn(
                        context,
                        icon: Icons.share_rounded,
                        label: t.share,
                        onTap: () async {
                          await ExportHelper.shareText(shareText);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _rowItem(BuildContext context, String title, String value) {
    final styleTitle = Theme.of(context).textTheme.bodyMedium;
    final styleValue = Theme.of(context).textTheme.bodyLarge;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$title: ', style: styleTitle),
        Expanded(child: Text(value, style: styleValue)),
      ],
    );
  }

  Widget _actionBtn(
    BuildContext context, {
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
