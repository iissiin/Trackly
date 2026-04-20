import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:trackly/core/theme/app_colors.dart';
import 'package:trackly/core/ui/app_dialogs.dart';
import 'package:trackly/core/ui/app_snackbar.dart';
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
          child: _buildCard(context, tracker),
        );
      },
      removeItemBuilder: (context, animation, oldItem) {
        return SizeFadeTransition(
          key: ValueKey(oldItem.id),
          sizeFraction: 0.7,
          curve: Curves.easeInOut,
          animation: animation,
          child: _buildCard(context, oldItem),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, TrackerModel tracker) {
    final isDone =
        tracker.statusFor(state.selectedDate, state.completions) ==
        TrackerFilter.completed;

    return Slidable(
      key: ValueKey(tracker.id),
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
        onToggle: () => context.read<TrackerBloc>().add(
          TrackerMarkToggled(tracker.id, isDone: isDone),
        ),
        onDelete: null,
      ),
    );
  }
}
