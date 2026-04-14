import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackly/core/theme/app_colors.dart';
import 'package:trackly/data/models/tracker_model.dart';
import 'package:trackly/features/screens/home_screen/bloc/tracker_bloc.dart';
import 'package:trackly/features/screens/home_screen/ui/tracker_card.dart';

class TrackerList extends StatelessWidget {
  final TrackerLoaded state;

  const TrackerList({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ImplicitlyAnimatedList<TrackerModel>(
      items: state.filtered,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      areItemsTheSame: (a, b) => a.id == b.id,
      itemBuilder: (context, animation, tracker, i) {
        return SizeFadeTransition(
          key: ValueKey(tracker.id),
          sizeFraction: 0.7,
          curve: Curves.easeInOut,
          animation: animation,
          child: _buildDismissibleCard(context, tracker),
        );
      },
      removeItemBuilder: (context, animation, oldItem) {
        return SizeFadeTransition(
          key: ValueKey(oldItem.id),
          sizeFraction: 0.7,
          curve: Curves.easeInOut,
          animation: animation,
          child: _buildDismissibleCard(context, oldItem),
        );
      },
    );
  }

  Widget _buildDismissibleCard(BuildContext context, TrackerModel tracker) {
    final isDone =
        tracker.statusFor(state.selectedDate, state.completions) ==
        TrackerFilter.completed;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Dismissible(
        key: ValueKey('dismiss_${tracker.id}'),
        direction: DismissDirection.endToStart,
        background: const _DeleteBackground(),
        onDismissed: (_) {
          context.read<TrackerBloc>().add(TrackerDeleted(tracker.id));
        },
        child: TrackerCard(
          tracker: tracker,
          completions: state.completions,
          selectedDate: state.selectedDate,
          onToggle: () => context.read<TrackerBloc>().add(
            TrackerMarkToggled(tracker.id, isDone: isDone),
          ),
          onDelete: null,
        ),
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFFFFF2F0)),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.delete_outline_rounded,
            color: appColors.accent,
            size: 22,
          ),
          const SizedBox(width: 8),
          const Text(
            'Удалить',
            style: TextStyle(
              color: appColors.accent,
              fontSize: 14,
              fontFamily: 'Nunito',
              fontVariations: [FontVariation('wght', 700)],
            ),
          ),
        ],
      ),
    );
  }
}
