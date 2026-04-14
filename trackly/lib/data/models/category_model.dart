/// Модель категории трекеров.
class CategoryModel {
  final String id;
  final String userId;
  final String name;
  final String emoji;
  final String colorHex;

  const CategoryModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.emoji,
    required this.colorHex,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json, String id) {
    return CategoryModel(
      id: id,
      userId: json['userId'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      colorHex: json['colorHex'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'name': name,
    'emoji': emoji,
    'colorHex': colorHex,
  };
}
