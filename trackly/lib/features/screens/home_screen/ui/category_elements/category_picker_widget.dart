import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackly/core/theme/app_colors.dart';
import 'package:trackly/data/models/category_model.dart';
import 'package:trackly/data/repositories/category_repository.dart';
import 'package:trackly/features/screens/home_screen/bloc/create_tracker_bloc.dart';
import 'package:trackly/features/screens/home_screen/ui/category_elements/category_dialogs.dart';
import 'package:trackly/features/screens/home_screen/ui/category_elements/category_list_item.dart';

class CategoryPickerSheet extends StatefulWidget {
  final List<CategoryModel> categories;
  final String? selectedId;

  const CategoryPickerSheet({
    super.key,
    required this.categories,
    this.selectedId,
  });

  @override
  State<CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<CategoryPickerSheet> {
  final _repo = CategoryRepository();
  late List<CategoryModel> _categories;

  @override
  void initState() {
    super.initState();
    _categories = List.from(widget.categories);
  }

  Future<void> _createCategory() async {
    final name = await showCategoryInputDialog(context);
    if (name == null) return;

    final cat = await _repo.createCategory(name);
    setState(() => _categories.add(cat));
  }

  Future<void> _editCategory(String id) async {
    final i = _categories.indexWhere((c) => c.id == id);
    if (i == -1) return;

    final name = await showCategoryInputDialog(
      context,
      title: 'Редактировать категорию',
      okLabel: 'Сохранить',
      initialText: _categories[i].name,
    );
    if (name == null) return;

    await _repo.updateCategory(id, name);
    setState(() => _categories[i] = _categories[i].copyWith(name: name));
  }

  Future<void> _deleteCategory(String id) async {
    await _repo.deleteCategory(id);
    setState(() => _categories.removeWhere((c) => c.id == id));
  }

  void _selectCategory(String? id) {
    context.read<CreateTrackerCubit>().setCategory(id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF5FAF6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          _DragHandle(),
          const SizedBox(height: 24),
          _Header(onCreateTap: _createCategory),
          const SizedBox(height: 16),
          _CategoryList(
            categories: _categories,
            selectedId: widget.selectedId,
            onSelect: (cat) =>
                _selectCategory(cat.id == widget.selectedId ? null : cat.id),
            onEdit: (cat) => _editCategory(cat.id),
            onDelete: (cat) => _deleteCategory(cat.id),
          ),
          const SizedBox(height: 16),
          _NoCategoryButton(onTap: () => _selectCategory(null)),
        ],
      ),
    );
  }
}

// ── Мелкие локальные виджеты ────────────────────────────────────────────────

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 5,
      decoration: BoxDecoration(
        color: appColors.border,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onCreateTap;

  const _Header({required this.onCreateTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Text(
            'Категории',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 20,
              color: appColors.text,
              fontVariations: const [FontVariation('wght', 800)],
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onCreateTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: appColors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    'Создать',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      color: Colors.white,
                      fontVariations: const [FontVariation('wght', 700)],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  final List<CategoryModel> categories;
  final String? selectedId;
  final ValueChanged<CategoryModel> onSelect;
  final ValueChanged<CategoryModel> onEdit;
  final ValueChanged<CategoryModel> onDelete;

  const _CategoryList({
    required this.categories,
    required this.selectedId,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Text(
          'Нет категорий',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
            color: appColors.textSub,
            fontVariations: const [FontVariation('wght', 600)],
          ),
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      child: ImplicitlyAnimatedList<CategoryModel>(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        items: categories,
        areItemsTheSame: (a, b) => a.id == b.id,
        itemBuilder: (context, animation, cat, _) {
          return SizeFadeTransition(
            key: ValueKey(cat.id),
            sizeFraction: 0.7,
            curve: Curves.easeInOut,
            animation: animation,
            child: _buildItem(cat),
          );
        },
        removeItemBuilder: (context, animation, cat) {
          return SizeFadeTransition(
            key: ValueKey(cat.id),
            sizeFraction: 0.7,
            curve: Curves.easeInOut,
            animation: animation,
            child: _buildItem(cat),
          );
        },
      ),
    );
  }

  Widget _buildItem(CategoryModel cat) {
    return CategoryListItem(
      category: cat,
      isSelected: cat.id == selectedId,
      onTap: () => onSelect(cat),
      onEdit: () => onEdit(cat),
      onDelete: () => onDelete(cat),
    );
  }
}

class _NoCategoryButton extends StatelessWidget {
  final VoidCallback onTap;

  const _NoCategoryButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: appColors.cardBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(Icons.block_rounded, size: 20, color: appColors.textSub),
              const SizedBox(width: 12),
              Text(
                'Без категории',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  color: appColors.textSub,
                  fontVariations: const [FontVariation('wght', 600)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
