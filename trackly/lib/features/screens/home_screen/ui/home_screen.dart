import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackly/core/theme/app_colors.dart';
import 'package:trackly/data/models/tracker_model.dart';
import 'package:trackly/data/repositories/category_repository.dart';
import 'package:trackly/data/repositories/tracker_repository.dart';
import 'package:trackly/features/screens/home_screen/bloc/tracker_bloc.dart';
import 'package:trackly/features/screens/home_screen/ui/calendar.dart';
import 'package:trackly/features/screens/home_screen/ui/tracker_list.dart';
import 'package:trackly/features/widgets/weather_widget/bloc/weather_bloc.dart';
import 'package:trackly/features/widgets/weather_widget/ui/weather_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => WeatherBloc()..add(WeatherLoadRequested())),
        BlocProvider(
          create: (_) =>
              TrackerBloc(TrackerRepository(), CategoryRepository())
                ..add(TrackerSubscribed(uid)),
        ),
      ],
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F2),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopBar(),
            BlocBuilder<TrackerBloc, TrackerState>(
              builder: (context, state) {
                final selected = state is TrackerLoaded
                    ? state.selectedDate
                    : DateTime.now();
                return CalendarStrip(
                  selectedDate: selected,
                  onDateChanged: (date) =>
                      context.read<TrackerBloc>().add(TrackerDateChanged(date)),
                );
              },
            ),
            const SizedBox(height: 5),
            BlocBuilder<TrackerBloc, TrackerState>(
              builder: (context, state) {
                if (state is! TrackerLoaded) return const SizedBox();
                return _FilterBar(activeFilter: state.activeFilter);
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<TrackerBloc, TrackerState>(
                builder: (context, state) {
                  if (state is TrackerLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is! TrackerLoaded) return const SizedBox();
                  return TrackerList(state: state);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// MARK: TOP BAR
class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName?.split(' ').first ?? 'друг';

    return Container(
      color: const Color(0xFFF2F5F2),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Привет, $name! 👋',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 26,
                    color: appColors.text,
                    fontVariations: const [FontVariation('wght', 900.0)],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/tracker/create'),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: appColors.green,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: appColors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const WeatherBarWidget(),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// MARK: FILTER BAR
class _FilterBar extends StatelessWidget {
  final TrackerFilter activeFilter;
  const _FilterBar({required this.activeFilter});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: PopupMenuButton<TrackerFilter>(
          initialValue: activeFilter,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: appColors.cardBg,
          elevation: 4,
          onSelected: (TrackerFilter filter) {
            context.read<TrackerBloc>().add(TrackerFilterChanged(filter));
          },
          itemBuilder: (BuildContext context) =>
              TrackerFilter.values.map((filter) {
                final isSelected = filter == activeFilter;
                return PopupMenuItem<TrackerFilter>(
                  value: filter,
                  child: Text(
                    _label(filter),
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      color: isSelected ? appColors.green : appColors.text,
                      fontVariations: [
                        FontVariation('wght', isSelected ? 700 : 500),
                      ],
                    ),
                  ),
                );
              }).toList(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: appColors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: appColors.border, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _label(activeFilter),
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    color: appColors.green,
                    fontVariations: const [FontVariation('wght', 700)],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: appColors.green,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _label(TrackerFilter f) => switch (f) {
    TrackerFilter.active => 'Активные',
    TrackerFilter.completed => 'Выполненные',
    TrackerFilter.missed => 'Пропущенные',
  };
}
