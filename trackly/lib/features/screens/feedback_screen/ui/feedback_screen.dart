// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trackly/core/theme/app_colors.dart';
import 'package:trackly/core/utils/app_snackbar.dart';
import 'package:trackly/data/repositories/feedback_repository.dart';
import 'package:trackly/features/screens/feedback_screen/bloc/feedback_screen_bloc.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FeedbackCubit(FeedbackRepository()),
      child: const _FeedbackView(),
    );
  }
}

class _FeedbackView extends StatefulWidget {
  const _FeedbackView();

  @override
  State<_FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<_FeedbackView> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF6),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: BlocBuilder<FeedbackCubit, FeedbackState>(
            builder: (context, state) => _SubmitButton(state: state),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: BlocBuilder<FeedbackCubit, FeedbackState>(
                builder: (context, state) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    children: [
                      _SectionLabel(label: 'Опишите проблему'),
                      const SizedBox(height: 8),
                      _MessageField(controller: _messageController),
                      const SizedBox(height: 20),
                      _SectionLabel(label: 'Скриншот (необязательно)'),
                      const SizedBox(height: 8),
                      _ImagePicker(state: state),
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

// MARK: HEADER

class _Header extends StatelessWidget {
  const _Header();

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
            'Сообщить о проблеме',
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

// MARK: SECTION LABEL

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 13,
        color: appColors.textSub,
        fontVariations: const [FontVariation('wght', 700)],
      ),
    );
  }
}

// MARK: MESSAGE FIELD

class _MessageField extends StatelessWidget {
  final TextEditingController controller;
  const _MessageField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: (v) => context.read<FeedbackCubit>().setMessage(v),
        maxLines: 6,
        minLines: 4,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 15,
          color: appColors.text,
          fontVariations: const [FontVariation('wght', 600)],
        ),
        decoration: InputDecoration(
          hintText: 'Что пошло не так?',
          hintStyle: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 15,
            color: appColors.textSub,
            fontVariations: const [FontVariation('wght', 500)],
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}

// MARK: IMAGE PICKER

class _ImagePicker extends StatelessWidget {
  final FeedbackState state;
  const _ImagePicker({required this.state});

  Future<void> _pick(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;
    if (!context.mounted) return;
    context.read<FeedbackCubit>().setImage(File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = state.image != null;

    return GestureDetector(
      onTap: () => _pick(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: hasImage ? 200 : 110,
        decoration: BoxDecoration(
          color: appColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasImage ? appColors.green : appColors.border,
            width: hasImage ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: hasImage
            ? _ImagePreview(image: state.image!)
            : _ImagePlaceholder(),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: appColors.mint,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.image_outlined, color: appColors.green, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          'Прикрепить скриншот',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            color: appColors.textSub,
            fontVariations: const [FontVariation('wght', 600)],
          ),
        ),
      ],
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final File image;
  const _ImagePreview({required this.image});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.file(image, fit: BoxFit.cover),
        ),
        // Кнопка удаления
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => context.read<FeedbackCubit>().clearImage(),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// MARK: SUBMIT BUTTON

class _SubmitButton extends StatelessWidget {
  final FeedbackState state;
  const _SubmitButton({required this.state});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: state.isSubmitting
          ? null
          : () async {
              final ok = await context.read<FeedbackCubit>().submit();
              if (!context.mounted) return;
              if (ok) {
                AppSnackbar.success(context, 'Сообщение отправлено');
                context.pop();
              } else {
                AppSnackbar.error(context, 'Не удалось отправить');
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
                  'Отправить',
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
