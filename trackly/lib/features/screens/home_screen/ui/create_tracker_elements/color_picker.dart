import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackly/core/theme/app_colors.dart';
import 'package:trackly/features/screens/home_screen/bloc/create_tracker_bloc.dart';
import 'package:trackly/features/screens/home_screen/ui/create_tracker_elements/shared_card.dart';

class ColorSection extends StatelessWidget {
  final CreateTrackerState state;
  const ColorSection({super.key, required this.state});

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
    return SharedCard(
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
                          // ignore: deprecated_member_use
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
