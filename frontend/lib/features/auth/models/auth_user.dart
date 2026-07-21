class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.createdAt,
  });

  final String id;
  final String email;
  final String displayName;
  final DateTime createdAt;

  AuthUser copyWith({String? displayName}) => AuthUser(
    id: id,
    email: email,
    displayName: displayName ?? this.displayName,
    createdAt: createdAt,
  );

  Map<String, Object> toJson() => {
    'id': id,
    'email': email,
    'displayName': displayName,
    'createdAt': createdAt.toUtc().toIso8601String(),
  };

  static AuthUser fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id'] as String,
    email: json['email'] as String,
    displayName: json['displayName'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
