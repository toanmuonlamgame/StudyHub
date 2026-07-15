import 'package:flutter/material.dart';

import 'app/learning_repository_config.dart';
import 'app/studyhub_app.dart';

void main() {
  runApp(
    StudyHubApp(
      learningRepository: createLearningRepositoryFromEnvironment(),
      contributionRepository: createContributionRepositoryFromEnvironment(),
    ),
  );
}

class MyApp extends StudyHubApp {
  const MyApp({super.key});
}
