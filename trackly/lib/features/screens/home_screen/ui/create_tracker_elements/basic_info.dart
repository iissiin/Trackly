import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackly/core/theme/app_colors.dart';
import 'package:trackly/features/screens/home_screen/bloc/create_tracker_bloc.dart';
import 'package:trackly/features/screens/home_screen/ui/create_tracker_elements/shared_card.dart';

class BasicInfoSection extends StatelessWidget {
  final CreateTrackerState state;
  const BasicInfoSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return SharedCard(
      child: Column(
        children: [
          InkWell(
            onTap: () => _showEmojiPicker(context),
            borderRadius: BorderRadius.circular(12),
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
                      Icons.tag_faces_rounded,
                      size: 18,
                      color: appColors.green,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              maxLength: 80,
              buildCounter:
                  (
                    _, {
                    required currentLength,
                    required isFocused,
                    maxLength,
                  }) => null,
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
