import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../features/home_placeholder.dart';

class StudyHubApp extends StatelessWidget {
  const StudyHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomePlaceholder(),
    );
  }
}
