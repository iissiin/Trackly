// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackly/core/theme/app_colors.dart';
import 'package:trackly/core/utils/app_snackbar.dart';
import 'package:trackly/data/models/tracker_model.dart';
import 'package:trackly/data/repositories/tracker_repository.dart';
import 'package:trackly/features/screens/home_screen/bloc/create_tracker_bloc.dart';
import 'package:trackly/features/screens/home_screen/ui/create_tracker/basic_info.dart';
import 'package:trackly/features/screens/home_screen/ui/create_tracker/schedule.dart';
import 'package:trackly/features/screens/home_screen/ui/create_tracker/category.dart';
import 'package:trackly/features/screens/home_screen/ui/create_tracker/color_picker.dart';
import 'package:trackly/features/screens/home_screen/ui/create_tracker/deadline.dart';
import 'package:trackly/features/screens/home_screen/ui/create_tracker/time_section.dart';

class CreateTrackerPage extends StatelessWidget {
  const CreateTrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateTrackerCubit(TrackerRepository()),
      child: const _CreateTrackerView(),
    );
  }
}

class _CreateTrackerView extends StatelessWidget {
  const _CreateTrackerView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF6),
      bottomNavigationBar: BlocBuilder<CreateTrackerCubit, CreateTrackerState>(
        builder: (context, state) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: _SubmitButton(state: state),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            Expanded(
              child: BlocBuilder<CreateTrackerCubit, CreateTrackerState>(
                builder: (context, state) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    children: [
                      _TypeSelector(state: state),
                      const SizedBox(height: 12),
                      BasicInfoSection(state: state),
                      const SizedBox(height: 12),
                      ColorSection(state: state),
                      const SizedBox(height: 12),
                      TimeSection(state: state),
                      const SizedBox(height: 12),
                      if (state.type == TrackerType.habit)
                        ScheduleSection(state: state),
                      if (state.type == TrackerType.irregular)
                        DeadlineSection(state: state),
                      const SizedBox(height: 12),
                      CategorySection(state: state),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// MARK: Header
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: appColors.cardBg,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: appColors.green.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: Color(0xFF718096),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            'Новый трекер',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 20,
              color: appColors.text,
              fontVariations: const [FontVariation('wght', 900)],
            ),
          ),
        ],
      ),
    );
  }
}

// MARK: Type selector
class _TypeSelector extends StatelessWidget {
  final CreateTrackerState state;
  const _TypeSelector({required this.state});

  static const _tabs = <(TrackerType, String)>[
    (TrackerType.habit, 'Привычка'),
    (TrackerType.irregular, 'Нерегулярное'),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _tabs.indexWhere((t) => t.$1 == state.type);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: appColors.border,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(3),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tabWidth = constraints.maxWidth / _tabs.length;

            return Stack(
              children: [
                // Плашка-индикатор — едет под строками
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  left: selectedIndex * tabWidth,
                  top: 0,
                  bottom: 0,
                  width: tabWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      color: appColors.cardBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                // Кликабельные ячейки
                Row(
                  children: [
                    for (final (type, label) in _tabs)
                      _tab(context, type, label),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _tab(BuildContext context, TrackerType type, String label) {
    final isActive = state.type == type;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.read<CreateTrackerCubit>().setType(type),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 220),
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              color: isActive ? appColors.green : appColors.textSub,
              fontVariations: const [FontVariation('wght', 700)],
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}

// MARK: Submit
class _SubmitButton extends StatelessWidget {
  final CreateTrackerState state;
  const _SubmitButton({required this.state});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: state.isSubmitting
          ? null
          : () async {
              final success = await context.read<CreateTrackerCubit>().submit();
              if (!context.mounted) return;
              if (success) {
                AppSnackbar.success(context, 'Трекер добавлен');
                context.pop();
              } else {
                AppSnackbar.error(context, 'Не удалось добавить трекер');
              }
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: state.isValid
                ? [appColors.green, const Color(0xFF3D5C41)]
                : [appColors.border, appColors.border],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: state.isValid
              ? [
                  BoxShadow(
                    color: appColors.green.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: state.isSubmitting
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  'Создать трекер',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    color: state.isValid ? Colors.white : appColors.textSub,
                    fontVariations: const [FontVariation('wght', 800)],
                  ),
                ),
        ),
      ),
    );
  }
}
