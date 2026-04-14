// ignore_for_file: deprecated_member_use

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackly/core/theme/app_colors.dart';
import 'package:trackly/data/models/tracker_model.dart';
import 'package:trackly/data/repositories/category_repository.dart';
import 'package:trackly/data/repositories/tracker_repository.dart';
import 'package:trackly/features/screens/home_screen/bloc/create_tracker_bloc.dart';
import 'package:trackly/features/screens/home_screen/ui/category_picker_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
                      _BasicInfoSection(state: state),
                      const SizedBox(height: 12),
                      _ColorSection(state: state),
                      const SizedBox(height: 12),
                      if (state.type == TrackerType.habit)
                        _ScheduleSection(state: state),
                      if (state.type == TrackerType.irregular)
                        _DeadlineSection(state: state),
                      const SizedBox(height: 12),
                      _CategorySection(state: state),
                      const SizedBox(height: 24),
                      _SubmitButton(state: state),
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: appColors.border,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(3),
        child: Row(
          children: [
            _tab(context, TrackerType.habit, 'Привычка', state),
            _tab(context, TrackerType.irregular, 'Нерегулярное', state),
          ],
        ),
      ),
    );
  }

  Widget _tab(
    BuildContext context,
    TrackerType type,
    String label,
    CreateTrackerState state,
  ) {
    final isActive = state.type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<CreateTrackerCubit>().setType(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: isActive ? appColors.cardBg : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                color: isActive ? appColors.green : appColors.textSub,
                fontVariations: const [FontVariation('wght', 700)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// MARK: Basic info (emoji + название)
class _BasicInfoSection extends StatelessWidget {
  final CreateTrackerState state;
  const _BasicInfoSection({required this.state});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        children: [
          // emoji picker row
          InkWell(
            onTap: () {
              _showEmojiPicker(context);
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5EE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('😊', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Эмодзи',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      color: appColors.text,
                      fontVariations: const [FontVariation('wght', 700)],
                    ),
                  ),
                  const Spacer(),
                  Text(state.emoji, style: const TextStyle(fontSize: 24)),
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
          Divider(height: 1, color: appColors.border),
          // title input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              onChanged: context.read<CreateTrackerCubit>().setTitle,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15,
                color: appColors.text,
                fontVariations: const [FontVariation('wght', 600)],
              ),
              decoration: InputDecoration(
                hintText: 'Название трекера',
                hintStyle: TextStyle(
                  fontFamily: 'Nunito',
                  color: appColors.textSub,
                  fontVariations: const [FontVariation('wght', 500)],
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEmojiPicker(BuildContext context) {
    final cubit = context.read<CreateTrackerCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: EmojiPicker(
            onEmojiSelected: (_, emoji) {
              cubit.setEmoji(emoji.emoji);
              Navigator.pop(sheetContext);
            },
            config: const Config(checkPlatformCompatibility: true),
          ),
        );
      },
    );
  }
}

// MARK: Color picker
class _ColorSection extends StatelessWidget {
  final CreateTrackerState state;
  const _ColorSection({required this.state});

  static const _colors = [
    '5A7A5E',
    'E8A07A',
    'C3B1E1',
    'AECBEB',
    'F4A7B9',
    'F9E4A0',
    'B5CCBA',
    '79828F',
  ];

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Цвет',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                color: appColors.text,
                fontVariations: const [FontVariation('wght', 700)],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _colors.map((hex) {
                final isSelected = state.colorHex == hex;
                final color = Color(int.parse('0xFF$hex'));
                return GestureDetector(
                  onTap: () => context.read<CreateTrackerCubit>().setColor(hex),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: isSelected
                          ? Border.all(color: appColors.cardBg, width: 2.5)
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// MARK: Schedule (для Habit)
class _ScheduleSection extends StatelessWidget {
  final CreateTrackerState state;
  const _ScheduleSection({required this.state});

  static const _days = [
    (Weekday.mon, 'Пн'),
    (Weekday.tue, 'Вт'),
    (Weekday.wed, 'Ср'),
    (Weekday.thu, 'Чт'),
    (Weekday.fri, 'Пт'),
    (Weekday.sat, 'Сб'),
    (Weekday.sun, 'Вс'),
  ];

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Расписание',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                color: appColors.text,
                fontVariations: const [FontVariation('wght', 700)],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _days.map(((Weekday, String) record) {
                final day = record.$1;
                final label = record.$2;
                final isSelected = state.schedule.contains(day);
                final accent = Color(int.parse('0xFF${state.colorHex}'));
                return GestureDetector(
                  onTap: () =>
                      context.read<CreateTrackerCubit>().toggleWeekday(day),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isSelected ? accent : appColors.border,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          color: isSelected ? Colors.white : appColors.textSub,
                          fontVariations: const [FontVariation('wght', 700)],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// MARK: Deadline (для Irregular)
class _DeadlineSection extends StatelessWidget {
  final CreateTrackerState state;
  const _DeadlineSection({required this.state});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now().add(const Duration(days: 1)),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            builder: (context, child) => Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(primary: appColors.green),
              ),
              child: child!,
            ),
          );
          if (picked != null && context.mounted) {
            context.read<CreateTrackerCubit>().setDeadline(picked);
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
                  color: const Color(0xFFE8F5EE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('📅', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Дедлайн',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  color: appColors.text,
                  fontVariations: const [FontVariation('wght', 700)],
                ),
              ),
              const Spacer(),
              Text(
                state.deadlineDate != null
                    ? '${state.deadlineDate!.day}.${state.deadlineDate!.month}.${state.deadlineDate!.year}'
                    : 'Не выбран',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  color: state.deadlineDate != null
                      ? appColors.green
                      : appColors.textSub,
                  fontVariations: const [FontVariation('wght', 600)],
                ),
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

// MARK: Category
class _CategorySection extends StatelessWidget {
  final CreateTrackerState state;
  const _CategorySection({required this.state});

  @override
  Widget build(BuildContext context) {
    return _Card(
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
                  color: const Color(0xFFEDE8F7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('🏷️', style: TextStyle(fontSize: 16)),
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
              Text(
                state.categoryId != null ? 'Выбрана' : 'Не выбрана',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  color: state.categoryId != null
                      ? appColors.green
                      : appColors.textSub,
                  fontVariations: const [FontVariation('wght', 600)],
                ),
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

// MARK: Shared card container
class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: appColors.green.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
