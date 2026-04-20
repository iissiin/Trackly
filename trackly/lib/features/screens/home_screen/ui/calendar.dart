import 'package:flutter/material.dart';
import 'package:trackly/core/theme/app_colors.dart';

class CalendarStrip extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const CalendarStrip({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  State<CalendarStrip> createState() => _CalendarStripState();
}

class _CalendarStripState extends State<CalendarStrip> {
  static const int _initialPage = 500;
  late PageController _pageController;
  late DateTime _today;
  late int _currentPageOffset;

  @override
  void initState() {
    super.initState();
    _today = _stripTime(DateTime.now());
    _pageController = PageController(initialPage: _initialPage);
    _currentPageOffset = 0;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _stripTime(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  DateTime _weekStart(int offset) {
    final monday = _today.subtract(Duration(days: _today.weekday - 1));
    return monday.add(Duration(days: offset * 7));
  }

  List<DateTime> _daysOfWeek(int offset) {
    final start = _weekStart(offset);
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  String _formatHeaderTitle(int offset) {
    final days = _daysOfWeek(offset);
    final firstDay = days.first;
    final lastDay = days.last;

    const months = [
      'Январь',
      'Февраль',
      'Март',
      'Апрель',
      'Май',
      'Июнь',
      'Июль',
      'Август',
      'Сентябрь',
      'Октябрь',
      'Ноябрь',
      'Декабрь',
    ];

    if (firstDay.month == lastDay.month) {
      return '${months[firstDay.month - 1]} ${firstDay.year}';
    } else {
      final firstMonthName = months[firstDay.month - 1];
      final lastMonthName = months[lastDay.month - 1];

      if (firstDay.year == lastDay.year) {
        return '$firstMonthName – $lastMonthName ${firstDay.year}';
      } else {
        return '$firstMonthName ${firstDay.year} – $lastMonthName ${lastDay.year}';
      }
    }
  }

  String _shortWeekday(int weekday) {
    const names = ['ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ', 'ВС'];
    return names[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          // ТЕПЕРЬ БЕЗ АНИМАЦИИ: просто текст, который перерисовывается через setState
          child: Text(
            _formatHeaderTitle(_currentPageOffset),
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 17,
              color: appColors.text,
              fontVariations: const [FontVariation('wght', 700)],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 78,
          child: PageView.builder(
            controller: _pageController,
            physics:
                const ClampingScrollPhysics(), // Более "строгий" скролл без пружинистости
            onPageChanged: (page) {
              setState(() {
                _currentPageOffset = page - _initialPage;
              });
            },
            itemBuilder: (context, page) {
              final offset = page - _initialPage;
              final days = _daysOfWeek(offset);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: days.map((day) {
                    final isToday = day == _today;
                    final isSelected = day == _stripTime(widget.selectedDate);
                    return GestureDetector(
                      onTap: () => widget.onDateChanged(day),
                      child: Container(
                        // Заменили AnimatedContainer на обычный Container
                        width: 53,
                        height: 75,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? appColors.green
                              : appColors.cardBg,
                          borderRadius: BorderRadius.circular(14),
                          border: isSelected
                              ? null
                              : Border.all(color: appColors.border, width: 1),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _shortWeekday(day.weekday),
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 9,
                                fontVariations: const [
                                  FontVariation('wght', 600),
                                ],
                                color: isSelected
                                    ? Colors.white.withOpacity(0.75)
                                    : appColors.textSub,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${day.day}',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 18,
                                fontVariations: const [
                                  FontVariation('wght', 700),
                                ],
                                color: isSelected
                                    ? appColors.cardBg
                                    : appColors.text,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isToday
                                    ? (isSelected
                                          ? appColors.white.withOpacity(0.55)
                                          : appColors.greenDark.withOpacity(
                                              0.5,
                                            ))
                                    : Colors.transparent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
