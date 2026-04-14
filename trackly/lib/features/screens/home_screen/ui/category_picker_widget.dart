import 'package:flutter/material.dart';
import 'package:trackly/data/models/category_model.dart';
import 'package:trackly/features/screens/home_screen/bloc/create_tracker_bloc.dart';
import 'package:trackly/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bottom sheet для выбора категории.
class CategoryPickerSheet extends StatelessWidget {
  final List<CategoryModel> categories;
  final String? selectedId;

  const CategoryPickerSheet({
    super.key,
    required this.categories,
    this.selectedId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF5FAF6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: appColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Категория',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 18,
              color: appColors.text,
              fontVariations: const [FontVariation('wght', 800)],
            ),
          ),
          const SizedBox(height: 16),
          if (categories.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Нет категорий',
                style: TextStyle(color: appColors.textSub),
              ),
            )
          else
            ...categories.map((cat) {
              final isSelected = cat.id == selectedId;
              final accent = Color(int.parse('0xFF${cat.colorHex}'));
              return ListTile(
                leading: Text(cat.emoji, style: const TextStyle(fontSize: 24)),
                title: Text(
                  cat.name,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    color: appColors.text,
                    fontVariations: const [FontVariation('wght', 700)],
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_rounded, color: accent)
                    : null,
                onTap: () {
                  context.read<CreateTrackerCubit>().setCategory(cat.id);
                  Navigator.pop(context);
                },
              );
            }),
          const SizedBox(height: 8),
          // кнопка "Без категории"
          ListTile(
            leading: const Text('🚫', style: TextStyle(fontSize: 24)),
            title: Text(
              'Без категории',
              style: TextStyle(
                fontFamily: 'Nunito',
                color: appColors.textSub,
                fontVariations: const [FontVariation('wght', 600)],
              ),
            ),
            onTap: () {
              context.read<CreateTrackerCubit>().setCategory(null);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
