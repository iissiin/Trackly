import 'package:flutter/material.dart';
import 'package:trackly/data/models/completion_model.dart';
import 'package:trackly/data/models/tracker_model.dart';

class _CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CheckmarkPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final p1 = Offset(size.width * 0.25, size.height * 0.50);
    final p2 = Offset(size.width * 0.42, size.height * 0.70);
    final p3 = Offset(size.width * 0.72, size.height * 0.35);

    final seg1Len = (p2 - p1).distance;
    final seg2Len = (p3 - p2).distance;
    final totalLen = seg1Len + seg2Len;

    final drawn = progress * totalLen;

    final path = Path();
    path.moveTo(p1.dx, p1.dy);

    if (drawn <= seg1Len) {
      final t = drawn / seg1Len;
      path.lineTo(p1.dx + (p2.dx - p1.dx) * t, p1.dy + (p2.dy - p1.dy) * t);
    } else {
      path.lineTo(p2.dx, p2.dy);
      final t = (drawn - seg1Len) / seg2Len;
      path.lineTo(p2.dx + (p3.dx - p2.dx) * t, p2.dy + (p3.dy - p2.dy) * t);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckmarkPainter old) => old.progress != progress;
}

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
  late Animation<double> _checkProgress;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _checkProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _checkController,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
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
  }

  String? _metaText() {
    if (widget.tracker.type == TrackerType.habit) return null;
    if (widget.tracker.deadlineDate == null) return null;
    final diff = widget.tracker.deadlineDate!.difference(DateTime.now()).inDays;
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
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        fontVariations: [FontVariation('wght', 700)],
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
              GestureDetector(
                onTap: _handleToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _isDone ? _accent : _accent.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: AnimatedBuilder(
                    animation: _checkProgress,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _CheckmarkPainter(
                          progress: _checkProgress.value,
                          color: Colors.white,
                        ),
                      );
                    },
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
