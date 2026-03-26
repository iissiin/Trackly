enum TrackerType { habit, task }

enum TrackerDay { mon, tue, wed, thu, fri, sat, sun }

class TrackerModel {
  final String id;
  final String uid;
  final String title;
  final String category;
  final String emoji;
  final String color;
  final TrackerType type;
  final List<TrackerDay> scheduledDays; // только для habit
  final int streak;
  final List<String> completedDates; // ISO 8601: '2025-03-26'
  final bool isArchived;
  final DateTime createdAt;

  const TrackerModel({
    required this.id,
    required this.uid,
    required this.title,
    required this.category,
    required this.emoji,
    required this.color,
    required this.type,
    this.scheduledDays = const [],
    this.streak = 0,
    this.completedDates = const [],
    this.isArchived = false,
    required this.createdAt,
  });

  bool isCompletedOn(DateTime date) {
    final key = _dateKey(date);
    return completedDates.contains(key);
  }

  bool get isScheduledToday {
    if (type == TrackerType.task) return true;
    final today =
        TrackerDay.values[(DateTime.now().weekday - 1) %
            7 // DateTime.monday = 1 → index 0
            ];
    return scheduledDays.contains(today);
  }

  factory TrackerModel.fromMap(String id, Map<String, dynamic> map) {
    return TrackerModel(
      id: id,
      uid: map['uid'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? 'Без категории',
      emoji: map['emoji'] ?? '💧',
      color: map['color'] ?? '#7db885',
      type: TrackerType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TrackerType.habit,
      ),
      scheduledDays: (map['scheduledDays'] as List<dynamic>? ?? [])
          .map((d) => TrackerDay.values.firstWhere((e) => e.name == d))
          .toList(),
      streak: map['streak'] ?? 0,
      completedDates: List<String>.from(map['completedDates'] ?? []),
      isArchived: map['isArchived'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'title': title,
    'category': category,
    'emoji': emoji,
    'color': color,
    'type': type.name,
    'scheduledDays': scheduledDays.map((d) => d.name).toList(),
    'streak': streak,
    'completedDates': completedDates,
    'isArchived': isArchived,
    'createdAt': createdAt.toIso8601String(),
  };

  TrackerModel copyWith({
    String? title,
    String? category,
    String? emoji,
    String? color,
    TrackerType? type,
    List<TrackerDay>? scheduledDays,
    int? streak,
    List<String>? completedDates,
    bool? isArchived,
  }) {
    return TrackerModel(
      id: id,
      uid: uid,
      title: title ?? this.title,
      category: category ?? this.category,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      type: type ?? this.type,
      scheduledDays: scheduledDays ?? this.scheduledDays,
      streak: streak ?? this.streak,
      completedDates: completedDates ?? this.completedDates,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt,
    );
  }

  static String _dateKey(DateTime date) =>
      date.toIso8601String().substring(0, 10);
}
