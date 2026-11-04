import 'dart:async';

import 'package:flutter/material.dart';

import 'app/learning_repository_config.dart';
import 'app/advertising_config.dart';
import 'app/studyhub_app.dart';
import 'features/media/services/picker_cache.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  PaintingBinding.instance.imageCache.maximumSizeBytes = 48 * 1024 * 1024;
  unawaited(pruneOldPickerCache());
  runApp(
    StudyHubApp(
      learningRepository: createLearningRepositoryFromEnvironment(),
      contributionRepository: createContributionRepositoryFromEnvironment(),
      attemptRepository: createAttemptRepositoryFromEnvironment(),
      authRepository: createAuthRepositoryFromEnvironment(),
      bookmarkRepository: createBookmarkRepositoryFromEnvironment(),
      mediaRepository: createMediaRepositoryFromEnvironment(),
      advertisingService: createAdvertisingServiceFromEnvironment(),
    ),
  );
}

class MyApp extends StudyHubApp {
  const MyApp({super.key});
}
