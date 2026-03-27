import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackly/core/theme/app_colors.dart';
import 'package:trackly/features/widgets/weather_widget/bloc/weather_bloc.dart';
import 'package:trackly/features/widgets/weather_widget/ui/weather_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WeatherBloc()..add(WeatherLoadRequested()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColors.mint,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPersistentHeader(pinned: true, delegate: _TopBarDelegate()),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 12),
                  const _EmptyState(),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBarDelegate extends SliverPersistentHeaderDelegate {
  static const double _height = 130.0;

  @override
  double get minExtent => _height;
  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: appColors.mint,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: _GreetingText()),
              const SizedBox(width: 12),
              _AddButton(),
            ],
          ),

          const SizedBox(height: 12),
          const WeatherBarWidget(),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _TopBarDelegate oldDelegate) => false;
}

// MARK: приветственный текст

class _GreetingText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName?.split(' ').first ?? 'друг';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Привет, $name! 👋',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 28,
            color: appColors.text,
            fontVariations: [FontVariation('wght', 900.0)],
          ),
        ),
      ],
    );
  }
}

// MARK: кнопка +

class _AddButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: открыть bottom sheet добавления трекера
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: appColors.green,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.add_rounded, color: appColors.white, size: 28),
      ),
    );
  }
}

// MARK: состояние экрана без трекеров

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          const Text('🌱', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 12),
          Text(
            'Нет трекеров',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 18,
              color: appColors.text,
              fontVariations: [FontVariation('wght', 800.0)],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Нажми + чтобы добавить первую привычку',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              color: appColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
