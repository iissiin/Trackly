import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:trackly/core/theme/app_colors.dart';
import 'package:trackly/core/utils/app_dialogs.dart';
import 'package:trackly/core/utils/app_snackbar.dart';
import 'package:trackly/data/models/tracker_model.dart';
import 'package:trackly/features/screens/home_screen/bloc/tracker_bloc.dart';
import 'package:trackly/features/screens/home_screen/ui/tracker_card.dart';

class TrackerList extends StatelessWidget {
  final TrackerLoaded state;
  const TrackerList({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final isEmpty = state.filtered.isEmpty;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: isEmpty
          ? _EmptyState(
              key: ValueKey('empty_${state.activeFilter.name}'),
              filter: state.activeFilter,
            )
          : ImplicitlyAnimatedList<TrackerModel>(
              key: ValueKey('list_${state.activeFilter.name}'),
              items: state.filtered,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              areItemsTheSame: (a, b) => a.id == b.id,
              itemBuilder: (context, animation, tracker, i) {
                return SizeFadeTransition(
                  key: ValueKey(tracker.id),
                  sizeFraction: 0.7,
                  curve: Curves.easeInOut,
                  animation: animation,
                  child: _TrackerListItem(tracker: tracker, state: state),
                );
              },
              removeItemBuilder: (context, animation, oldItem) {
                return SizeFadeTransition(
                  key: ValueKey(oldItem.id),
                  sizeFraction: 0.7,
                  curve: Curves.easeInOut,
                  animation: animation,
                  child: _TrackerListItem(tracker: oldItem, state: state),
                );
              },
            ),
    );
  }
}

// MARK: - TrackerStateWrapper

class TrackerStateWrapper extends StatelessWidget {
  const TrackerStateWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TrackerBloc, TrackerState>(
      listenWhen: (prev, curr) => curr is TrackerError && prev is! TrackerError,
      listener: (context, state) {
        AppSnackbar.error(context, 'Не удалось получить трекеры');
      },
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: switch (state) {
            TrackerLoaded() => TrackerList(
              key: const ValueKey('loaded'),
              state: state,
            ),
            TrackerError() => _ErrorState(key: const ValueKey('error')),
            TrackerLoading() => const _LoadingState(key: ValueKey('loading')),
            _ => const SizedBox.shrink(key: ValueKey('initial')),
          },
        );
      },
    );
  }
}

// MARK: - States

class _LoadingState extends StatelessWidget {
  const _LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 48, 20, 100),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(appColors.green),
          strokeWidth: 2.5,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 100),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Что-то пошло не так',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15,
                fontVariations: [FontVariation('wght', 700)],
                color: appColors.text,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Не удалось загрузить трекеры.\nПроверьте соединение и попробуйте снова.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                fontVariations: [FontVariation('wght', 500)],
                color: appColors.textSub,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => context.read<TrackerBloc>().add(TrackerRetried()),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: appColors.green,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Повторить',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontVariations: [FontVariation('wght', 700)],
                    color: appColors.mint,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final TrackerFilter filter;

  const _EmptyState({super.key, required this.filter});

  ({String title, String subtitle}) get _content => switch (filter) {
    TrackerFilter.active => (
      title: 'На сегодня всё',
      subtitle: 'Нет активных трекеров.\nДобавьте новый или измените фильтр.',
    ),
    TrackerFilter.completed => (
      title: 'Пока ничего не выполнено',
      subtitle: 'Отмечайте трекеры как выполненные,\nи они появятся здесь.',
    ),
    TrackerFilter.missed => (
      title: 'Ничего не пропущено',
      subtitle: 'Отлично! Все трекеры в порядке.',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final c = _content;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 100),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              c.title,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15,
                fontVariations: [FontVariation('wght', 700)],
                color: appColors.text,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              c.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                fontVariations: [FontVariation('wght', 500)],
                color: appColors.textSub,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// MARK: - List item

class _TrackerListItem extends StatefulWidget {
  final TrackerModel tracker;
  final TrackerLoaded state;

  const _TrackerListItem({required this.tracker, required this.state});

  @override
  State<_TrackerListItem> createState() => _TrackerListItemState();
}

class _TrackerListItemState extends State<_TrackerListItem>
    with SingleTickerProviderStateMixin {
  late final SlidableController _slidableController;

  @override
  void initState() {
    super.initState();
    _slidableController = SlidableController(this);
  }

  @override
  void dispose() {
    _slidableController.dispose();
    super.dispose();
  }

  bool get _isOpen => _slidableController.ratio != 0;

  @override
  Widget build(BuildContext context) {
    final tracker = widget.tracker;
    final state = widget.state;
    final isDone =
        tracker.statusFor(state.selectedDate, state.completions) ==
        TrackerFilter.completed;

    return Slidable(
      key: ValueKey(tracker.id),
      controller: _slidableController,
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.35,
        children: [
          SlidableAction(
            onPressed: (_) {
              context.push('/tracker/edit/${tracker.id}', extra: tracker);
            },
            backgroundColor: Colors.transparent,
            foregroundColor: appColors.greenDark,
            icon: Icons.edit_rounded,
            spacing: 8,
          ),
          SlidableAction(
            onPressed: (_) async {
              final confirmed = await AppDialogs.confirmDelete(
                context,
                message: 'Трекер будет удалён.',
              );
              if (confirmed && context.mounted) {
                context.read<TrackerBloc>().add(TrackerDeleted(tracker.id));
                AppSnackbar.success(context, 'Удалено');
              }
            },
            backgroundColor: Colors.transparent,
            foregroundColor: appColors.accent,
            icon: Icons.delete_outline_rounded,
            spacing: 8,
          ),
        ],
      ),
      child: TrackerCard(
        tracker: tracker,
        completions: state.completions,
        selectedDate: state.selectedDate,
        categoryName: state.categoryNameFor(tracker.categoryId),
        onCardTap: () {
          if (_isOpen) _slidableController.close();
        },
        onToggle: () {
          if (_isOpen) {
            _slidableController.close();
            return;
          }
          context.read<TrackerBloc>().add(
            TrackerMarkToggled(tracker.id, isDone: isDone),
          );
        },
      ),
    );
  }
}
