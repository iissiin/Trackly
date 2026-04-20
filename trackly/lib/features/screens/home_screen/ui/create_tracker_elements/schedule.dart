// MARK: Schedule
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackly/core/theme/app_colors.dart';
import 'package:trackly/data/models/tracker_model.dart';
import 'package:trackly/features/screens/home_screen/bloc/create_tracker_bloc.dart';
import 'package:trackly/features/screens/home_screen/ui/create_tracker_elements/shared_card.dart';

class ScheduleSection extends StatelessWidget {
  final CreateTrackerState state;
  const ScheduleSection({super.key, required this.state});

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
    return SharedCard(
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
