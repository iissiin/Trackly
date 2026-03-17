class userModel {
  final String uid;
  final String name;
  final String email;

  userModel({required this.uid, required this.name, required this.email});

  factory userModel.fromMap(String uid, Map<String, dynamic> map) {
    return userModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {'name': name, 'email': email};

  userModel copyWith({String? name}) {
    return userModel(uid: uid, name: name ?? this.name, email: email);
  }
}
