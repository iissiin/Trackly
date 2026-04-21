import 'package:flutter/material.dart';
import 'package:trackly/data/models/completion_model.dart';
import 'package:trackly/data/models/tracker_model.dart';

class TrackerCard extends StatefulWidget {
  final TrackerModel tracker;
  final List<CompletionModel> completions;
  final DateTime selectedDate;
  final String? categoryName;
  final VoidCallback? onToggle;
  final VoidCallback? onCardTap;

  const TrackerCard({
    super.key,
    required this.tracker,
    required this.completions,
    required this.selectedDate,
    this.categoryName,
    this.onToggle,
    this.onCardTap,
  });

  @override
  State<TrackerCard> createState() => _TrackerCardState();
}

class _TrackerCardState extends State<TrackerCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _checkController;
  late Animation<double> _checkScale;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _checkScale = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.easeInOut),
    );
    if (_isDone) _checkController.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant TrackerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isDone) {
      _checkController.forward();
    } else {
      _checkController.reverse();
    }
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  bool get _isDone =>
      widget.tracker.statusFor(widget.selectedDate, widget.completions) ==
      TrackerFilter.completed;

  bool get _isMissed =>
      widget.tracker.statusFor(widget.selectedDate, widget.completions) ==
      TrackerFilter.missed;

  Color get _accent => Color(int.parse('0xFF${widget.tracker.colorHex}'));
  Color get _accentBg => _accent.withValues(alpha: 0.18);

  void _handleToggle() {
    widget.onToggle?.call();
    if (!_isDone) {
      _checkController.forward().then((_) => _checkController.reverse());
    } else {
      _checkController.reverse();
    }
  }

  String? _metaText() {
    if (widget.tracker.type == TrackerType.habit) return null;
    if (widget.tracker.deadlineDate == null) return null;
    final diff = widget.tracker.deadlineDate!.difference(DateTime.now()).inDays;
    if (diff < 0) return 'Просрочено';
    if (diff == 0) return 'Дедлайн сегодня!';
    if (diff <= 3) return 'Осталось $diff дн.';
    final d = widget.tracker.deadlineDate!;
    return 'До ${d.day}.${d.month}.${d.year}';
  }

  bool get _hasSubtext =>
      widget.categoryName != null || _metaText() != null || _isMissed;

  @override
  Widget build(BuildContext context) {
    final meta = _metaText();

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onCardTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 9),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: _accentBg,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              // Emoji box
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.28),
                  borderRadius: BorderRadius.circular(13),
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.tracker.emoji,
                  style: const TextStyle(fontSize: 30),
                ),
              ),

              const SizedBox(width: 11),

              // Title + subtext
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.tracker.title,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        fontVariations: const [FontVariation('wght', 700)],
                        decoration: _isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    if (_hasSubtext) ...[
                      const SizedBox(height: 3),
                      DefaultTextStyle(
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 10,
                          color: Colors.black.withValues(alpha: 0.45),
                          fontVariations: const [FontVariation('wght', 600)],
                        ),
                        child: Row(
                          children: [
                            if (widget.categoryName != null)
                              Text(widget.categoryName!),

                            if (widget.categoryName != null &&
                                (meta != null || _isMissed)) ...[
                              const SizedBox(width: 4),
                              const Text('·'),
                              const SizedBox(width: 4),
                            ],

                            if (meta != null) Text(meta),

                            if (_isMissed) ...[
                              if (meta != null) ...[
                                const SizedBox(width: 4),
                                const Text('·'),
                                const SizedBox(width: 4),
                              ],
                              const Text(
                                'Пропущено',
                                style: TextStyle(color: Color(0xFFE05050)),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Check button
              ScaleTransition(
                scale: _checkScale,
                child: GestureDetector(
                  onTap: _handleToggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _isDone
                          ? _accent
                          : _accent.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 16,
                      color: _isDone
                          ? Colors.white
                          : _accent.withValues(alpha: 0.65),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
