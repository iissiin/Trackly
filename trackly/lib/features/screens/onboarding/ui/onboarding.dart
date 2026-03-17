import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackly/features/screens/onboarding/bloc/onboardingBloc.dart';

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
    return Stack(
      children: [
        // Фон
        Container(color: const Color(0xFFF0EFFF)),

        // Блобы — повторяют HTML-верстку
        const _Blob(
          color: Color(0xFFB5AEFF),
          width: 260,
          height: 260,
          top: -60,
          left: -80,
          opacity: 0.55,
        ),
        const _Blob(
          color: Color(0xFF7C6FFF),
          width: 180,
          height: 180,
          top: 80,
          right: -60,
          opacity: 0.35,
        ),
        const _Blob(
          color: Color(0xFFCBC6FF),
          width: 220,
          height: 220,
          bottom: 100,
          left: -70,
          opacity: 0.4,
        ),
        const _Blob(
          color: Color(0xFF9D94FF),
          width: 160,
          height: 160,
          bottom: -40,
          right: -40,
          opacity: 0.45,
        ),

        // Контент
        SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Логотип — два пересекающихся круга как в HTML
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 8,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: Color(0xFF6C63FF),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 8,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFF9D94FF).withOpacity(0.75),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // trackly
                  const Text(
                    'trackly',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D2A6E),
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Заголовок
                  const Text(
                    'Добро пожаловать! 👋',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2A6E),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  // Подзаголовок
                  const Text(
                    'Начни формировать полезные привычки уже сегодня',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF7B78B0),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 52),

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
    );
  }
}

// ─── Кнопка входа через Google ────────────────────────

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
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.15),
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
                    color: Color(0xFF6C63FF),
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google G иконка
                  _GoogleIcon(),
                  const SizedBox(width: 12),
                  const Text(
                    'Войти через Google',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2A6E),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// SVG-like Google G через CustomPaint
class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _GoogleIconPainter()),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  const _GoogleIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double r = size.width / 2;

    // Синий сектор (верх-правый)
    _drawSector(canvas, cx, cy, r, -90, 90, const Color(0xFF4285F4));
    // Красный сектор (верх-левый)
    _drawSector(canvas, cx, cy, r, -180, 90, const Color(0xFFEA4335));
    // Жёлтый сектор (низ-левый)
    _drawSector(canvas, cx, cy, r, 90, 90, const Color(0xFFFBBC05));
    // Зелёный сектор (низ-правый)
    _drawSector(canvas, cx, cy, r, 180, 90, const Color(0xFF34A853));

    // Белый центральный круг
    canvas.drawCircle(Offset(cx, cy), r * 0.55, Paint()..color = Colors.white);

    // Синяя «полочка» G
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTRB(cx, cy - r * 0.13, cx + r, cy + r * 0.13),
      barPaint,
    );
  }

  void _drawSector(
    Canvas canvas,
    double cx,
    double cy,
    double r,
    double startDeg,
    double sweepDeg,
    Color color,
  ) {
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawArc(
      rect,
      startDeg * 3.14159 / 180,
      sweepDeg * 3.14159 / 180,
      true,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Блоб ─────────────────────────────────────────────

class _Blob extends StatelessWidget {
  final Color color;
  final double width;
  final double height;
  final double opacity;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  const _Blob({
    required this.color,
    required this.width,
    required this.height,
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
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(width / 2),
          ),
        ),
      ),
    );
  }
}
