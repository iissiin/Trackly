import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackly/core/theme/app_colors.dart';
import 'package:trackly/data/repositories/category_repository.dart';
import 'package:trackly/data/repositories/tracker_repository.dart';
import 'package:trackly/features/screens/statistic_screen/bloc/statistic_bloc.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return BlocProvider(
      create: (_) => StatisticBloc(TrackerRepository(), CategoryRepository())
        ..add(StatisticSubscribed(uid)),
      child: const _StatisticsView(),
    );
  }
}

class _StatisticsView extends StatelessWidget {
  const _StatisticsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF6),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                'Статистика',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 26,
                  color: appColors.text,
                  fontVariations: const [FontVariation('wght', 900)],
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<StatisticBloc, StatisticState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(appColors.green),
                        strokeWidth: 2.5,
                      ),
                    );
                  }

                  if (state.hasError) {
                    return Center(
                      child: Text(
                        'Не удалось загрузить статистику',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          color: appColors.textSub,
                          fontVariations: const [FontVariation('wght', 600)],
                        ),
                      ),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              value:
                                  '${state.completedToday}/${state.totalToday}',
                              label: 'Выполнено\nсегодня',
                              progress: state.totalToday == 0
                                  ? 0
                                  : state.completedToday / state.totalToday,
                              color: appColors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              value: '${state.activeTrackers}',
                              label: 'Активных\nтрекеров',
                              progress: state.totalToday == 0
                                  ? 0
                                  : state.activeTrackers / state.totalToday,
                              color: const Color(0xFF64B5F6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              value: '${state.totalTrackers}',
                              label: 'Всего\nсоздано',
                              progress: null,
                              color: const Color(0xFFB39DDB),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              value: '${state.bestStreak}',
                              label: 'Лучшая серия\n(дней)',
                              progress: null,
                              color: const Color(0xFFF4A585),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _StatCardWide(
                        value: '${state.completedThisWeek}',
                        label: 'Выполнено за неделю',
                        progress: state.totalTrackers == 0
                            ? 0
                            : (state.completedThisWeek /
                                    (state.totalTrackers * 7))
                                .clamp(0.0, 1.0),
                        color: appColors.green,
                      ),
                      const SizedBox(height: 12),
                      _CategoryCard(topCategory: state.topCategory),
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

// ─────────────────────────────────────────────
// MARK: Карточка 1/2 ширины
// ─────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final double? progress;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 34,
              color: appColors.text,
              fontVariations: const [FontVariation('wght', 300)],
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              color: appColors.textSub,
              fontVariations: const [FontVariation('wght', 600)],
              height: 1.4,
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: 14),
            _ProgressBar(value: progress!, color: color),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MARK: Широкая карточка
// ─────────────────────────────────────────────

class _StatCardWide extends StatelessWidget {
  final String value;
  final String label;
  final double progress;
  final Color color;

  const _StatCardWide({
    required this.value,
    required this.label,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 34,
              color: appColors.text,
              fontVariations: const [FontVariation('wght', 300)],
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              color: appColors.textSub,
              fontVariations: const [FontVariation('wght', 600)],
            ),
          ),
          const SizedBox(height: 14),
          _ProgressBar(value: progress, color: color),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MARK: Карточка категории
// ─────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final String? topCategory;

  const _CategoryCard({required this.topCategory});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: appColors.mint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.star_rounded,
              color: appColors.green,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Самая популярная категория',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  color: appColors.textSub,
                  fontVariations: const [FontVariation('wght', 600)],
                ),
              ),
              const SizedBox(height: 3),
              Text(
                topCategory ?? 'Нет категорий',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 17,
                  color: topCategory != null
                      ? appColors.text
                      : appColors.textSub,
                  fontVariations: const [FontVariation('wght', 800)],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MARK: Прогресс-бар
// ─────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  final double value;
  final Color color;

  const _ProgressBar({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Container(
          height: 8,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: width * value.clamp(0.0, 1.0),
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.65), color],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}