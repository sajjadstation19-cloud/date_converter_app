import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// زر بتدرج لوني + أنيميشن ضغط + هتزاز تفاعلي
class GradientButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double elevation;

  const GradientButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.padding = const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    this.borderRadius = 16,
    this.elevation = 4,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      lowerBound: 0.0,
      upperBound: 0.06,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null) _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null) _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;

    // 🌿 تدرج لوني ديناميكي أخضر
    const gradient = LinearGradient(
      colors: [Color(0xFF5D8A6A), Color(0xFF4E7D5B)], // فاتح → غامق
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: 20, color: Colors.white),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            widget.label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 0.3,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isDisabled ? 0.5 : 1,
      child: Material(
        color: Colors.transparent,
        elevation: widget.elevation,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Ink(
          decoration: BoxDecoration(
            gradient: isDisabled ? null : gradient,
            color: isDisabled ? Theme.of(context).disabledColor : null,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            splashColor: Colors.white.withOpacity(0.15),
            highlightColor: Colors.transparent,
            onTap: isDisabled
                ? null
                : () {
                    Feedback.forTap(context); // ✅ هتزاز صوتي
                    HapticFeedback.lightImpact(); // ✅ هتزاز لمسي
                    widget.onPressed?.call();
                  },
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: () => _controller.reverse(),
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Padding(padding: widget.padding, child: child),
            ),
          ),
        ),
      ),
    );
  }
}
