class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.createdAt,
    this.avatarUrl,
    this.role = 'user',
    this.status = 'active',
  });

  final String id;
  final String email;
  final String displayName;
  final DateTime createdAt;
  final String? avatarUrl;
  final String role;
  final String status;

  AuthUser copyWith({
    String? displayName,
    String? avatarUrl,
    bool removeAvatar = false,
  }) => AuthUser(
    id: id,
    email: email,
    displayName: displayName ?? this.displayName,
    createdAt: createdAt,
    avatarUrl: removeAvatar ? null : avatarUrl ?? this.avatarUrl,
    role: role,
    status: status,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'email': email,
    'displayName': displayName,
    'avatarUrl': avatarUrl,
    'role': role,
    'status': status,
    'createdAt': createdAt.toUtc().toIso8601String(),
  };

  static AuthUser fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id'] as String,
    email: json['email'] as String,
    displayName: json['displayName'] as String,
    avatarUrl: json['avatarUrl'] as String?,
    role: json['role'] as String? ?? 'user',
    status: json['status'] as String? ?? 'active',
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
