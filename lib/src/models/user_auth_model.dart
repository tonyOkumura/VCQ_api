// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserAuth {
  final String email;
  final String password;

  UserAuth({
    required this.email,
    required this.password,
  });

  UserAuth copyWith({
    String? email,
    String? password,
  }) {
    return UserAuth(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'password': password,
    };
  }

  factory UserAuth.fromMap(Map<String, dynamic> map) {
    return UserAuth(
      email: map['email'] as String,
      password: map['password'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserAuth.fromJson(Map<String, dynamic> json) {
    return UserAuth(
        email: json['email'] ?? '', password: json['password'] ?? '');
  }

  @override
  String toString() => 'UserAuth(email: $email, password: $password)';

  @override
  bool operator ==(covariant UserAuth other) {
    if (identical(this, other)) return true;

    return other.email == email && other.password == password;
  }

  @override
  int get hashCode => email.hashCode ^ password.hashCode;
}
