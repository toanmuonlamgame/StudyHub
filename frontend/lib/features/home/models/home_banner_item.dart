import 'package:flutter/material.dart';

enum HomeBannerTone { primary, success, neutral }

class HomeBannerItem {
  const HomeBannerItem({
    required this.icon,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onPressed,
    required this.tone,
  });

  final IconData icon;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onPressed;
  final HomeBannerTone tone;
}
