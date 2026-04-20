import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackly/core/theme/app_colors.dart';
import 'package:trackly/features/screens/home_screen/bloc/create_tracker_bloc.dart';
import 'package:trackly/features/screens/home_screen/ui/create_tracker_elements/shared_card.dart';

class DeadlineSection extends StatelessWidget {
  final CreateTrackerState state;
  const DeadlineSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return SharedCard(
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
                  color: appColors.mint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: appColors.green,
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
