class User {
  final int id;
  final String firstName;
  final String lastName;
  final String name;
  final String email;
  final String? language;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.name,
    required this.email,
    this.language,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      language: json['language'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'name': name,
      'email': email,
      'language': language,
    };
  }
}
