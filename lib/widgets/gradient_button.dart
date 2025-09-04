import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    this.padding = const EdgeInsets.symmetric(vertical: 16),
    this.borderRadius = 12,
    this.elevation = 3,
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
      upperBound: 0.05,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    if (widget.onPressed != null) _controller.forward();
  }

  void _onTapUp(_) {
    if (widget.onPressed != null) _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;

    const gradient = LinearGradient(
      colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)], // أخضر فاتح → داكن
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: 20, color: Colors.white),
          const SizedBox(width: 8),
        ],
        Text(
          widget.label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
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
            onTap: isDisabled
                ? null
                : () {
                    Feedback.forTap(context);
                    HapticFeedback.lightImpact();
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
