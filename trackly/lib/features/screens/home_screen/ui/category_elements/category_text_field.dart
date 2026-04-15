import 'package:flutter/material.dart';
import 'package:trackly/core/theme/app_colors.dart';

class CategoryTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool autofocus;

  const CategoryTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: appColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: appColors.border),
      ),
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 16,
          color: appColors.text,
          fontVariations: const [FontVariation('wght', 600)],
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: 'Nunito',
            color: appColors.textSub,
            fontVariations: const [FontVariation('wght', 500)],
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
