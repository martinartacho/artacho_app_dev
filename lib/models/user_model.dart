class UserModel {
  final int id;
  final String name;
  final String email;
  final String? token;
  final String? createdAt; // Nuevo campo para fecha de creación

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.token,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      token: json['token'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'token': token,
    'created_at': createdAt,
  };
}
