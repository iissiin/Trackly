import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackly/core/theme/app_colors.dart';
import 'package:trackly/features/screens/home_screen/bloc/home_screen_bloc.dart';
import 'package:trackly/features/widgets/weather_widget/bloc/weather_bloc.dart';
import 'package:trackly/features/widgets/weather_widget/ui/weather_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => WeatherBloc()..add(WeatherLoadRequested())),
        BlocProvider(
          create: (_) => TrackersBloc()..add(TrackersLoadRequested()),
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
      backgroundColor: appColors.mint,
      body: SafeArea(
        child: BlocBuilder<TrackersBloc, TrackersState>(
          builder: (context, state) {
            if (state is TrackersLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final hasTrackers =
                state is TrackersLoaded && state.activeTrackersCount > 0;

            return CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TopBarDelegate(),
                ),

                if (!hasTrackers)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: _EmptyState()),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 12),
                        // TODO: список трекеров
                        const SizedBox(height: 24),
                      ]),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// MARK: TOP BAR
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

// MARK: GREETING
class _GreetingText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName?.split(' ').first ?? 'друг';

    return Text(
      'Привет, $name! 👋',
      style: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 28,
        color: appColors.text,
        fontVariations: [FontVariation('wght', 900.0)],
      ),
    );
  }
}

// MARK: ADD BUTTON
class _AddButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _AddButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          onTap ??
          () {
            context.read<TrackersBloc>().add(TrackerAdded());
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

// MARK: EMPTY STATE
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Нажми + чтобы добавить первую привычку',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              color: appColors.textSub,
            ),
          ),
        ),
      ],
    );
  }
}
