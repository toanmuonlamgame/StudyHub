import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../features/learning/repositories/learning_repository.dart';
import '../features/learning/repositories/mock_learning_repository.dart';
import 'main_navigation_screen.dart';

class StudyHubApp extends StatelessWidget {
  const StudyHubApp({
    super.key,
    this.learningRepository = const MockLearningRepository(),
  });

  final LearningRepository learningRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: MainNavigationScreen(learningRepository: learningRepository),
    );
  }
}
