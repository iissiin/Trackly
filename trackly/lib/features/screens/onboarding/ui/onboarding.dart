// ignore_for_file: deprecated_member_use

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trackly/core/theme/app_colors.dart';
import 'package:trackly/features/screens/onboarding/bloc/onboarding_bloc.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider<OnboardingBloc>(
        create: (_) => OnboardingBloc(),
        child: BlocListener<OnboardingBloc, OnboardingState>(
          listener: (context, state) {
            if (state is OnboardingSuccessState) {
              context.go('/home');
            }
          },
          child: const _OnboardingBody(),
        ),
      ),
    );
  }
}

class _OnboardingBody extends StatelessWidget {
  const _OnboardingBody();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.6, 1.0],
          colors: [appColors.mint, Colors.white],
        ),
      ),
      child: Stack(
        children: [
          _Blob(
            color: appColors.peach,
            w: 300,
            h: 300,
            top: -40,
            left: -60,
            opacity: 0.55,
          ),
          _Blob(
            color: appColors.lavender,
            w: 230,
            h: 230,
            top: 90,
            left: 90,
            opacity: 0.55,
          ),
          _Blob(
            color: appColors.peach,
            w: 150,
            h: 150,
            top: -20,
            right: -50,
            opacity: 0.55,
          ),
          _Blob(
            color: appColors.lavender,
            w: 150,
            h: 150,
            bottom: 200,
            left: -60,
            opacity: 0.55,
          ),
          _Blob(
            color: appColors.peach,
            w: 280,
            h: 280,
            bottom: -10,
            right: -30,
            opacity: 0.55,
          ),
          _Blob(
            color: appColors.lavender,
            w: 150,
            h: 150,
            bottom: -7,
            left: 120,
            opacity: 0.55,
          ),

          // ── Основной контент ──
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 40,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 8,
                            top: 15,
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: appColors.peach.withOpacity(0.9),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 8,
                            top: 12,
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: appColors.lavender.withOpacity(0.9),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Название приложения
                    const Text(
                      'trackly',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 42,
                        height: 1.1,
                        fontVariations: [FontVariation('wght', 900.0)],
                        color: appColors.green,
                        letterSpacing: -1,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Приветствие
                    const Text(
                      'Добро пожаловать! 👋',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 26,
                        fontVariations: [FontVariation('wght', 800.0)],
                        color: appColors.text,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    // Подзаголовок
                    const Text(
                      'Начни формировать полезные\nпривычки уже сегодня',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 15,
                        color: appColors.textSub,
                        fontVariations: [FontVariation('wght', 400.0)],
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 48),

                    // Кнопка Google
                    Builder(
                      builder: (context) {
                        final state = context.watch<OnboardingBloc>().state;
                        final isLoading = state is OnboardingLoadingState;

                        return _GoogleSignInButton(
                          isLoading: isLoading,
                          onTap: () {
                            context.read<OnboardingBloc>().add(
                              OnboardingAuthWithGoogleEvent(),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Кнопка «Войти через Google»

class _GoogleSignInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _GoogleSignInButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: appColors.green.withOpacity(0.20),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: appColors.green,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/onboarding/googleicon.svg',
                    width: 22,
                    height: 22,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Войти через Google',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontVariations: [FontVariation('wght', 700.0)],
                      color: appColors.text,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// декорация на фон

class _Blob extends StatelessWidget {
  final Color color;
  final double w, h, opacity;
  final double? top, bottom, left, right;

  const _Blob({
    required this.color,
    required this.w,
    required this.h,
    required this.opacity,
    this.top,
    this.bottom,
    this.left,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: 50, sigmaY: 28),
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: w,
            height: h,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}
