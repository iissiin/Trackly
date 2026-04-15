import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext;
import 'package:trackly/core/theme/app_colors.dart';
import 'package:trackly/features/screens/home_screen/bloc/create_tracker_bloc.dart';
import 'package:trackly/features/screens/home_screen/ui/create_tracker_elements/shared_card.dart';

class TimeSection extends StatelessWidget {
  final CreateTrackerState state;
  const TimeSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final hasTime = state.reminderTime != null;
    return SharedCard(
      child: InkWell(
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: state.reminderTime ?? TimeOfDay.now(),
            initialEntryMode: TimePickerEntryMode.input,
            builder: (context, child) => Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(primary: appColors.green),
                timePickerTheme: TimePickerThemeData(
                  backgroundColor: appColors.cardBg,
                ),
              ),
              child: child!,
            ),
          );
          if (context.mounted) {
            context.read<CreateTrackerCubit>().setReminderTime(picked);
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
                  color: appColors.peach.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: appColors.peach,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Время напоминания',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  color: appColors.text,
                  fontVariations: const [FontVariation('wght', 700)],
                ),
              ),
              const Spacer(),
              if (hasTime) ...[
                Text(
                  _formatTime(state.reminderTime!),
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    color: appColors.green,
                    fontVariations: const [FontVariation('wght', 700)],
                  ),
                ),
                const SizedBox(width: 8),
                // кнопка сброса
                GestureDetector(
                  onTap: () =>
                      context.read<CreateTrackerCubit>().setReminderTime(null),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: appColors.textSub,
                  ),
                ),
              ] else ...[
                Text(
                  'Не выбрано',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    color: appColors.textSub,
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
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
