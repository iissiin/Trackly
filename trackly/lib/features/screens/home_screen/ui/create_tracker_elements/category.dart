import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackly/core/theme/app_colors.dart';
import 'package:trackly/data/repositories/category_repository.dart';
import 'package:trackly/features/screens/home_screen/bloc/create_tracker_bloc.dart';
import 'package:trackly/features/screens/home_screen/ui/category_elements/category_picker_widget.dart';
import 'package:trackly/features/screens/home_screen/ui/create_tracker_elements/shared_card.dart';

class CategorySection extends StatelessWidget {
  final CreateTrackerState state;

  const CategorySection({super.key, required this.state});

  Future<String> _getCategoryLabel() async {
    if (state.categoryId == null) return 'Не выбрана';

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final categories = await CategoryRepository().watchCategories(uid).first;
    final cat = categories.firstWhereOrNull((c) => c.id == state.categoryId);
    return cat?.name ?? 'Не выбрана';
  }

  @override
  Widget build(BuildContext context) {
    return SharedCard(
      child: InkWell(
        onTap: () async {
          final uid = FirebaseAuth.instance.currentUser!.uid;
          final categories = await CategoryRepository()
              .watchCategories(uid)
              .first;
          if (context.mounted) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => BlocProvider.value(
                value: context.read<CreateTrackerCubit>(),
                child: CategoryPickerSheet(
                  categories: categories,
                  selectedId: state.categoryId,
                ),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: appColors.lavender.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.label_rounded,
                  size: 16,
                  color: appColors.lavender,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Категория',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  color: appColors.text,
                  fontVariations: const [FontVariation('wght', 700)],
                ),
              ),
              const Spacer(),
              FutureBuilder<String>(
                key: ValueKey(state.categoryId),
                future: _getCategoryLabel(),
                builder: (context, snapshot) {
                  if (state.categoryId == null) {
                    return Text(
                      'Не выбрана',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        color: appColors.textSub,
                        fontVariations: const [FontVariation('wght', 600)],
                      ),
                    );
                  }

                  final label = snapshot.data ?? '...';
                  return Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      color: snapshot.hasData
                          ? appColors.green
                          : appColors.textSub,
                      fontVariations: const [FontVariation('wght', 600)],
                    ),
                  );
                },
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                color: appColors.textSub,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
