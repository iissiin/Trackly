class UserModel {
  final String uid;
  final String name;
  final String email;
  final bool notificationsEnabled;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.notificationsEnabled = true,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      notificationsEnabled: map['notificationsEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'notificationsEnabled': notificationsEnabled,
  };
}
