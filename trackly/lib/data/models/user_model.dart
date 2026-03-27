class UserModel {
  final String uid;
  final String name;
  final String email;

  UserModel({required this.uid, required this.name, required this.email});

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {'name': name, 'email': email};

  UserModel copyWith({String? name}) {
    return UserModel(uid: uid, name: name ?? this.name, email: email);
  }
}
