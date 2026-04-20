import 'package:flutter/material.dart';
import 'package:trackly/data/models/completion_model.dart';
import 'package:trackly/data/models/tracker_model.dart';

class TrackerCard extends StatefulWidget {
  final TrackerModel tracker;
  final List<CompletionModel> completions;
  final DateTime selectedDate;
  final VoidCallback? onToggle;
  final VoidCallback? onCardTap;

  const TrackerCard({
    super.key,
    required this.tracker,
    required this.completions,
    required this.selectedDate,
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

  @override
  Widget build(BuildContext context) {
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
            color: _isDone
                ? _accentBg
                : _isMissed
                ? const Color(0xFFFFF5F5)
                : _accentBg,
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

              // Title + Meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.tracker.title,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        fontVariations: const [FontVariation('wght', 700)],
                        color: _isMissed
                            ? const Color(0xFFAAAAAA)
                            : const Color(0xFF1A1A1A),
                        decoration: _isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          _metaText(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFFAAAAAA),
                          ),
                        ),
                        if (_isMissed) ...[
                          const SizedBox(width: 4),
                          const Text(
                            '·',
                            style: TextStyle(color: Color(0xFFAAAAAA)),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Пропущено',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFFE05050),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Check button — только здесь toggle
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

  String _metaText() {
    if (widget.tracker.type == TrackerType.habit) {
      const dayNames = {
        Weekday.mon: 'Пн',
        Weekday.tue: 'Вт',
        Weekday.wed: 'Ср',
        Weekday.thu: 'Чт',
        Weekday.fri: 'Пт',
        Weekday.sat: 'Сб',
        Weekday.sun: 'Вс',
      };
      final days = widget.tracker.schedule.map((d) => dayNames[d]!).join(', ');
      return days.isEmpty ? 'Каждый день' : days;
    } else {
      if (widget.tracker.deadlineDate == null) return 'Нерегулярное';
      final diff = widget.tracker.deadlineDate!
          .difference(DateTime.now())
          .inDays;
      if (diff < 0) return 'Просрочено';
      if (diff == 0) return 'Дедлайн сегодня!';
      if (diff <= 3) return 'Осталось $diff дн.';
      final d = widget.tracker.deadlineDate!;
      return 'До ${d.day}.${d.month}.${d.year}';
    }
  }
}
