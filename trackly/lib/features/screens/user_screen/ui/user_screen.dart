// ignore_for_file: deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trackly/core/services/notification/notification_service.dart';
import 'package:trackly/core/theme/app_colors.dart';
import 'package:trackly/core/theme/app_images.dart';
import 'package:trackly/core/utils/app_dialogs.dart';
import 'package:trackly/core/utils/app_snackbar.dart';
import 'package:trackly/data/repositories/user_repository.dart';
import 'package:trackly/features/screens/user_screen/bloc/user_screen_bloc.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserCubit(UserRepository()),
      child: const _UserView(),
    );
  }
}

class _UserView extends StatefulWidget {
  const _UserView();

  @override
  State<_UserView> createState() => _UserViewState();
}

class _UserViewState extends State<_UserView> {
  late TextEditingController _nameController;
  String _originalName = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserCubit, UserState>(
      listenWhen: (prev, curr) => prev.isLoading && !curr.isLoading,
      listener: (context, state) {
        _originalName = state.name;
        _nameController.text = state.name;
        _nameController.selection = TextSelection.collapsed(
          offset: state.name.length,
        );
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5FAF6),
        body: SafeArea(
          child: Column(
            children: [
              const _Header(),
              Expanded(
                child: BlocBuilder<UserCubit, UserState>(
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: appColors.green,
                        ),
                      );
                    }
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      children: [
                        _AvatarSection(),
                        const SizedBox(height: 20),
                        _SectionLabel(label: 'Имя'),
                        const SizedBox(height: 8),
                        _NameField(controller: _nameController),

                        // ← Кнопка появляется здесь
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _nameController,
                          builder: (context, value, child) {
                            final hasChanges =
                                value.text.trim() != _originalName.trim() &&
                                value.text.trim().isNotEmpty;

                            return AnimatedSize(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeOutCubic,
                              child: hasChanges
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: _SaveButton(
                                        state: state,
                                        onSaved: () {
                                          setState(() {
                                            _originalName = state.name;
                                          });
                                        },
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            );
                          },
                        ),

                        const SizedBox(height: 20),
                        _SectionLabel(label: 'Настройки'),
                        const SizedBox(height: 8),
                        _SettingsCard(state: state),
                        const SizedBox(height: 20),
                        _SectionLabel(label: 'Поддержка'),
                        const SizedBox(height: 8),
                        _SupportCard(),
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
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
          Text(
            'Профиль',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 26,
              color: appColors.text,
              fontVariations: const [FontVariation('wght', 900)],
            ),
          ),
        ],
      ),
    );
  }
}

// MARK: AVATAR

class _AvatarSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';

    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: appColors.cardBg,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: SvgPicture.asset(
              AppImages.googleIcon,
              width: 28,
              height: 28,
            ),
          ),
        ),
        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<UserCubit, UserState>(
                builder: (context, state) => Text(
                  state.name.isEmpty ? 'Без имени' : state.name,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    color: appColors.text,
                    fontVariations: const [FontVariation('wght', 800)],
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                email,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  color: appColors.textSub,
                  fontVariations: const [FontVariation('wght', 500)],
                ),
              ),
            ],
          ),
        ),

        GestureDetector(
          onTap: () async {
            final confirmed = await AppDialogs.confirmDelete(
              context,
              title: 'Выйти из аккаунта?',
              message: 'Вы уверены, что хотите выйти?',
              deleteLabel: 'Выйти',
            );
            if (!confirmed || !context.mounted) return;
            await context.read<UserCubit>().signOut();
            if (!context.mounted) return;
            context.go('/onboarding');
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEDED),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.logout_rounded,
              size: 18,
              color: Color(0xFFD9534F),
            ),
          ),
        ),
      ],
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

// MARK: NAME FIELD

class _NameField extends StatelessWidget {
  final TextEditingController controller;
  const _NameField({required this.controller});

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
        onChanged: (v) => context.read<UserCubit>().setName(v),
        maxLength: 30,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 15,
          color: appColors.text,
          fontVariations: const [FontVariation('wght', 600)],
        ),
        decoration: InputDecoration(
          hintText: 'Введите имя',
          hintStyle: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 15,
            color: appColors.textSub,
            fontVariations: const [FontVariation('wght', 500)],
          ),
          prefixIcon: Icon(
            Icons.person_outline_rounded,
            color: appColors.textSub,
            size: 20,
          ),
          counterText: '', // убираем "0/30"
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

// MARK: SETTINGS CARD

class _SettingsCard extends StatelessWidget {
  final UserState state;
  const _SettingsCard({required this.state});

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
      child: Column(
        children: [
          _SettingsRow(
            icon: Icons.notifications_outlined,
            label: 'Уведомления',
            trailing: Switch.adaptive(
              value: state.notificationsEnabled,
              onChanged: (v) async {
                final success = await context
                    .read<UserCubit>()
                    .toggleNotifications(v);

                if (!success && v && context.mounted) {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(
                        'Уведомления выключены',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontVariations: [FontVariation('wght', 800)],
                        ),
                      ),
                      content: Text(
                        'Разрешите уведомления в настройках телефона',
                        style: TextStyle(fontFamily: 'Nunito'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(
                            'Отмена',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              color: appColors.textSub,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await NotificationService().openSettings();
                          },
                          child: Text(
                            'Настройки',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              color: appColors.green,
                              fontVariations: [FontVariation('wght', 700)],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
              activeColor: appColors.green,
            ),
          ),
          _Divider(),
          _SettingsRow(
            icon: Icons.language_outlined,
            label: 'Язык',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Русский', // TODO: localization not implemented yet
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
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
            ),
            onTap: () {
              // TODO: localization not implemented yet
            },
          ),
        ],
      ),
    );
  }
}

// MARK: SUPPORT CARD

class _SupportCard extends StatelessWidget {
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
      child: _SettingsRow(
        icon: Icons.flag_outlined,
        label: 'Сообщить о проблеме',
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: appColors.textSub,
          size: 20,
        ),
        onTap: () => context.push('/feedback'),
      ),
    );
  }
}

// MARK: SHARED ROW

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: appColors.mint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: appColors.green, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 15,
                  color: appColors.text,
                  fontVariations: const [FontVariation('wght', 600)],
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, color: appColors.border);
  }
}

// MARK: SAVE BUTTON

class _SaveButton extends StatelessWidget {
  final UserState state;
  final VoidCallback onSaved;

  const _SaveButton({required this.state, required this.onSaved});

  @override
  Widget build(BuildContext context) {
    final isValid = state.name.trim().isNotEmpty;

    return GestureDetector(
      onTap: state.isSaving
          ? null
          : () async {
              final ok = await context.read<UserCubit>().saveName();
              if (!context.mounted) return;
              if (ok) {
                AppSnackbar.success(context, 'Изменения применены');
                onSaved();
              } else {
                AppSnackbar.error(context, 'Не удалось сохранить');
              }
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isValid
                ? [appColors.green, const Color(0xFF3D5C41)]
                : [appColors.border, appColors.border],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isValid
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
          child: state.isSaving
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  'Сохранить',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    color: isValid ? Colors.white : appColors.textSub,
                    fontVariations: const [FontVariation('wght', 800)],
                  ),
                ),
        ),
      ),
    );
  }
}
