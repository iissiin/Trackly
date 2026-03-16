import 'package:flutter/material.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _today;
  late DateTime _selectedDay;
  late PageController _pageController;


  @override
  void initState() {
    super.initState();
    _today = _stripTime(DateTime.now());
    _selectedDay = _today;
    _pageController = PageController(initialPage: 500); 
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _stripTime(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  
  DateTime _weekStart(int offset) {
    final monday = _today.subtract(Duration(days: _today.weekday - 1));
    return monday.add(Duration(days: offset * 7));
  }

  List<DateTime> _daysOfWeek(int offset) {
    final start = _weekStart(offset);
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  String _formatHeaderDate(DateTime dt) {
    const months = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _shortWeekday(int weekday) {
    const names = ['ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ', 'ВС'];
    return names[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         
          const SizedBox(height: 157),

         
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              _formatHeaderDate(_selectedDay),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D2D2D),
              ),
            ),
          ),

          const SizedBox(height: 16),

          
          SizedBox(
            height: 90,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (_) {},
              itemBuilder: (context, page) {
                final offset = page - 500;
                final days = _daysOfWeek(offset);
                return _WeekRow(
                  days: days,
                  today: _today,
                  selectedDay: _selectedDay,
                  shortWeekday: _shortWeekday,
                  onDayTap: (day) {
                    setState(() {
                      _selectedDay = day;
                    });
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 24),

         
          Center(
            child: _MonthIndicator(selectedDay: _selectedDay),
          ),
        ],
      ),
    );
  }
}


class _WeekRow extends StatelessWidget {
  final List<DateTime> days;
  final DateTime today;
  final DateTime selectedDay;
  final String Function(int) shortWeekday;
  final ValueChanged<DateTime> onDayTap;

  const _WeekRow({
    required this.days,
    required this.today,
    required this.selectedDay,
    required this.shortWeekday,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days
            .map((day) => _DayCard(
                  day: day,
                  isToday: day == today,
                  isSelected: day == selectedDay,
                  weekdayLabel: shortWeekday(day.weekday),
                  onTap: () => onDayTap(day),
                ))
            .toList(),
      ),
    );
  }
}


class _DayCard extends StatelessWidget {
  final DateTime day;
  final bool isToday;
  final bool isSelected;
  final String weekdayLabel;
  final VoidCallback onTap;

  const _DayCard({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.weekdayLabel,
    required this.onTap,
  });

  
  static const _activeBackground = Color(0xFF3D6B5E);   
  static const _todayDot = Color(0xFF3D6B5E);
  static const _cardBackground = Color(0xFFFFFFFF);
  static const _cardBorder = Color(0xFFE0E0D8);

  @override
  Widget build(BuildContext context) {
    final bool highlighted = isSelected;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 46,
        height: 82,
        decoration: BoxDecoration(
          color: highlighted ? _activeBackground : _cardBackground,
          borderRadius: BorderRadius.circular(22),
          border: highlighted
              ? null
              : Border.all(color: _cardBorder, width: 1),
          boxShadow: highlighted
              ? [
                  BoxShadow(
                    color: _activeBackground.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            Text(
              weekdayLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: highlighted
                    ? Colors.white.withValues(alpha: 0.85)
                    : const Color(0xFF9E9E9E),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            
            Text(
              day.day.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: highlighted ? Colors.white : const Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 6),
            
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isToday
                    ? (highlighted
                        ? Colors.white.withValues(alpha: 0.7)
                        : _todayDot.withValues(alpha: 0.5))
                    : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _MonthIndicator extends StatelessWidget {
  final DateTime selectedDay;

  const _MonthIndicator({required this.selectedDay});

  static const _months = [
    'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
    'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь',
  ];

  @override
  Widget build(BuildContext context) {
    return Text(
      '${_months[selectedDay.month - 1]} ${selectedDay.year}',
      style: const TextStyle(
        fontSize: 13,
        color: Color(0xFFAAAAAA),
        letterSpacing: 0.4,
      ),
    );
  }
}
