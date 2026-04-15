class CategoryModel {
  final String id;
  final String userId;
  final String name;

  const CategoryModel({
    required this.id,
    required this.userId,
    required this.name,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json, String id) {
    return CategoryModel(
      id: id,
      userId: json['userId'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'userId': userId, 'name': name};

  CategoryModel copyWith({String? id, String? userId, String? name}) {
    return CategoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
    );
  }
}
