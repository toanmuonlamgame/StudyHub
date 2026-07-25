import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../auth/models/auth_user.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.user,
    this.radius = 32,
    this.previewBytes,
  });

  final AuthUser user;
  final double radius;
  final List<int>? previewBytes;

  @override
  Widget build(BuildContext context) {
    final fallback = Center(
      child: Text(
        _initials(user.displayName),
        style: TextStyle(
          fontSize: radius * .62,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
    final url = user.avatarUrl;
    return Semantics(
      image: true,
      label: user.displayName,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: ClipOval(
          child: SizedBox.square(
            dimension: radius * 2,
            child: previewBytes != null
                ? Image.memory(
                    Uint8List.fromList(previewBytes!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => fallback,
                  )
                : url == null
                ? fallback
                : Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => fallback,
                  ),
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty);
    final values = parts
        .take(2)
        .map((part) => part.characters.first.toUpperCase());
    final result = values.join();
    return result.isEmpty ? '?' : result;
  }
}
