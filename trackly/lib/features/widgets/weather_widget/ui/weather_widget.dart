// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trackly/data/models/weather_model.dart';
import '../bloc/weather_bloc.dart';

class WeatherBarWidget extends StatelessWidget {
  const WeatherBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherBloc, WeatherState>(
      builder: (context, state) {
        if (state is WeatherLoading || state is WeatherInitial) {
          return const _WeatherBarSkeleton();
        } else if (state is WeatherLoaded) {
          return _WeatherBarContent(weather: state.weather);
        } else if (state is WeatherError) {
          return _WeatherBarError(
            onRetry: () =>
                context.read<WeatherBloc>().add(WeatherLoadRequested()),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// ─── Loaded ───────────────────────────────────────────

class _WeatherBarContent extends StatelessWidget {
  final WeatherModel weather;

  const _WeatherBarContent({required this.weather});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _WeatherBarShell(
      child: Row(
        children: [
          Text(weather.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${weather.temperature.round()}°',
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  weather.description,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12,
                    color: colorScheme.onSurface.withOpacity(0.55),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 11,
                color: colorScheme.onSurface.withOpacity(0.45),
              ),
              const SizedBox(width: 2),
              Text(
                weather.cityName,
                style: GoogleFonts.nunitoSans(
                  fontSize: 12,
                  color: colorScheme.onSurface.withOpacity(0.55),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Loading skeleton ─────────────────────────────────

class _WeatherBarSkeleton extends StatefulWidget {
  const _WeatherBarSkeleton();

  @override
  State<_WeatherBarSkeleton> createState() => _WeatherBarSkeletonState();
}

class _WeatherBarSkeletonState extends State<_WeatherBarSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _opacity = Tween<double>(
      begin: 0.35,
      end: 0.75,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).colorScheme.outlineVariant;

    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, _) {
        return _WeatherBarShell(
          child: Opacity(
            opacity: _opacity.value,
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SkeletonLine(width: 40, height: 13, color: borderColor),
                      const SizedBox(height: 5),
                      _SkeletonLine(width: 110, height: 11, color: borderColor),
                    ],
                  ),
                ),
                _SkeletonLine(width: 60, height: 11, color: borderColor),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const _SkeletonLine({
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// ─── Error ────────────────────────────────────────────

class _WeatherBarError extends StatelessWidget {
  final VoidCallback onRetry;

  const _WeatherBarError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _WeatherBarShell(
      child: Row(
        children: [
          Icon(Icons.cloud_off_rounded, size: 20, color: colorScheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Не удалось получить погоду',
              style: GoogleFonts.nunitoSans(
                fontSize: 12,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          GestureDetector(
            onTap: onRetry,
            child: Text(
              'Повторить',
              style: GoogleFonts.nunitoSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shell (общая обёртка карточки) ──────────────────

class _WeatherBarShell extends StatelessWidget {
  final Widget child;

  const _WeatherBarShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5A7A5E).withOpacity(0.09),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
