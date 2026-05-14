import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:trackly/core/theme/app_colors.dart';
import 'package:trackly/data/models/category_model.dart';

class CategoryListItem extends StatefulWidget {
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
  State<CategoryListItem> createState() => _CategoryListItemState();
}

class _CategoryListItemState extends State<CategoryListItem>
    with SingleTickerProviderStateMixin {
  late final SlidableController _slidableController;

  @override
  void initState() {
    super.initState();
    _slidableController = SlidableController(this);
  }

  @override
  void dispose() {
    _slidableController.dispose();
    super.dispose();
  }

  bool get _isOpen => _slidableController.ratio != 0;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(widget.category.id),
      controller: _slidableController,
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.35,
        children: [
          CustomSlidableAction(
            onPressed: (_) => widget.onEdit(),
            backgroundColor: Colors.transparent,
            child: Icon(
              Icons.edit_rounded,
              color: appColors.greenDark,
              size: 23,
            ),
          ),
          CustomSlidableAction(
            onPressed: (_) => widget.onDelete(),
            backgroundColor: Colors.transparent,
            child: Icon(
              Icons.delete_outline_rounded,
              color: appColors.accent,
              size: 23,
            ),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          if (_isOpen) {
            _slidableController.close();
            return;
          }
          widget.onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? appColors.green.withValues(alpha: 0.1)
                : appColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isSelected
                  ? appColors.green.withValues(alpha: 0.4)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.category.name,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    color: appColors.text,
                    fontVariations: const [FontVariation('wght', 600)],
                  ),
                ),
              ),
              if (widget.isSelected)
                Icon(Icons.check_rounded, color: appColors.green, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
