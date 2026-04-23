// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:trackly/core/theme/app_colors.dart';

enum SnackbarType { success, error, info }

class AppSnackbar {
  AppSnackbar._();

  static void show(
    BuildContext context, {
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 2),
  }) {
    final (icon, bg, textColor) = switch (type) {
      SnackbarType.success => (
        Icons.check_circle_rounded,
        appColors.green,
        appColors.mint,
      ),
      SnackbarType.error => (
        Icons.cancel_rounded,
        const Color(0xFFD9534F),
        const Color(0xFFFFEDED),
      ),
      SnackbarType.info => (
        Icons.info_rounded,
        appColors.textSub,
        appColors.mint,
      ),
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          margin: const EdgeInsets.fromLTRB(4, 0, 4, 24),
          animation: CurvedAnimation(
            parent: ProxyAnimation(kAlwaysCompleteAnimation),
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInOutBack,
          ),
          content: _SnackbarContent(
            message: message,
            icon: icon,
            bg: bg,
            textColor: textColor,
            duration: duration,
          ),
        ),
      );
  }

  static void success(BuildContext context, String message) =>
      show(context, message: message, type: SnackbarType.success);
  static void error(BuildContext context, String message) =>
      show(context, message: message, type: SnackbarType.error);
  static void info(BuildContext context, String message) =>
      show(context, message: message, type: SnackbarType.info);
}

class _SnackbarContent extends StatefulWidget {
  const _SnackbarContent({
    required this.message,
    required this.icon,
    required this.bg,
    required this.textColor,
    required this.duration,
  });

  final String message;
  final IconData icon;
  final Color bg;
  final Color textColor;
  final Duration duration;

  @override
  State<_SnackbarContent> createState() => _SnackbarContentState();
}

class _SnackbarContentState extends State<_SnackbarContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeOutAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeOutAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    Future.delayed(widget.duration - const Duration(milliseconds: 400), () {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeOutAnimation,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 300),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.scale(scale: 0.95 + (0.05 * value), child: child),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.bg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: widget.textColor, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.message,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    color: widget.textColor,
                    fontVariations: const [FontVariation('wght', 700)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
