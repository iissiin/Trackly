import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:trackly/core/theme/app_colors.dart';
import 'package:trackly/data/models/category_model.dart';

class CategoryListItem extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CategoryListItem({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(category.id),
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.35,
        children: [
          SlidableAction(
            onPressed: (_) => onEdit(),
            backgroundColor: Colors.transparent,
            foregroundColor: appColors.greenDark,
            icon: Icons.edit_rounded,
            spacing: 8,
          ),
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: Colors.transparent,
            foregroundColor: appColors.accent,
            icon: Icons.delete_outline_rounded,
            spacing: 8,
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? appColors.green.withValues(alpha: 0.1)
                : appColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? appColors.green.withValues(alpha: 0.4)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  category.name,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    color: appColors.text,
                    fontVariations: const [FontVariation('wght', 600)],
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check_rounded, color: appColors.green, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
