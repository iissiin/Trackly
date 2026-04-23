// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackly/core/theme/app_colors.dart';
import 'package:trackly/data/models/tracker_model.dart';
import 'package:trackly/data/repositories/tracker_repository.dart';
import 'package:trackly/features/screens/home_screen/bloc/create_tracker_bloc.dart';
import 'package:trackly/features/screens/home_screen/ui/create_tracker_elements/basic_info.dart';
import 'package:trackly/features/screens/home_screen/ui/create_tracker_elements/category.dart';
import 'package:trackly/features/screens/home_screen/ui/create_tracker_elements/color_picker.dart';
import 'package:trackly/features/screens/home_screen/ui/create_tracker_elements/deadline.dart';
import 'package:trackly/features/screens/home_screen/ui/create_tracker_elements/schedule.dart';
import 'package:trackly/features/screens/home_screen/ui/create_tracker_elements/time_section.dart';

class EditTrackerPage extends StatelessWidget {
  final TrackerModel tracker;
  const EditTrackerPage({super.key, required this.tracker});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          CreateTrackerCubit.fromTracker(TrackerRepository(), tracker),
      child: _EditTrackerView(tracker: tracker),
    );
  }
}

class _EditTrackerView extends StatelessWidget {
  final TrackerModel tracker;
  const _EditTrackerView({required this.tracker});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF6),
      body: SafeArea(
        child: Column(
          children: [
            _EditHeader(),
            Expanded(
              child: BlocBuilder<CreateTrackerCubit, CreateTrackerState>(
                builder: (context, state) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    children: [
                      _TypeLabel(type: tracker.type),
                      const SizedBox(height: 12),
                      BasicInfoSection(state: state),
                      const SizedBox(height: 12),
                      ColorSection(state: state),
                      const SizedBox(height: 12),
                      TimeSection(state: state),
                      const SizedBox(height: 12),
                      if (tracker.type == TrackerType.habit)
                        ScheduleSection(state: state),
                      if (tracker.type == TrackerType.irregular)
                        DeadlineSection(state: state),
                      const SizedBox(height: 12),
                      CategorySection(state: state),
                      const SizedBox(height: 24),
                      _SaveButton(tracker: tracker),
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
class _EditHeader extends StatelessWidget {
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
            'Редактировать',
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

// MARK: Type label — тип менять нельзя, просто показываем
class _TypeLabel extends StatelessWidget {
  final TrackerType type;
  const _TypeLabel({required this.type});

  @override
  Widget build(BuildContext context) {
    final label = type == TrackerType.habit ? 'Привычка' : 'Нерегулярное';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: appColors.border,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              color: appColors.green,
              fontVariations: const [FontVariation('wght', 700)],
            ),
          ),
        ),
      ),
    );
  }
}

// MARK: Save button
class _SaveButton extends StatelessWidget {
  final TrackerModel tracker;
  const _SaveButton({required this.tracker});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateTrackerCubit, CreateTrackerState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: state.isSubmitting
              ? null
              : () async {
                  final success = await context
                      .read<CreateTrackerCubit>()
                      .update(tracker.id, tracker.userId, tracker.createdAt);
                  if (success && context.mounted) context.pop();
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
                      'Сохранить',
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
      },
    );
  }
}
