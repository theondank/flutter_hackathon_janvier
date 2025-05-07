class User {
  final int? id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final String? token;

  User({
    this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user']['id'] ?? json['id'],
      name: json['user']['name'] ?? json['name'],
      email: json['user']['email'] ?? json['email'],
      emailVerifiedAt: json['user']['email_verified_at'] ?? json['email_verified_at'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'email_verified_at': emailVerifiedAt,
    'token': token,
  };
}