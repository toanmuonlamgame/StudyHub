import 'dart:async';

import 'package:flutter/material.dart';

import '../core/app_locale.dart';
import '../core/app_theme.dart';
import '../core/locale_preference_store.dart';
import '../features/learning/repositories/learning_repository.dart';
import '../features/learning/repositories/mock_learning_repository.dart';
import '../features/contribution/repositories/contribution_repository.dart';
import '../features/contribution/repositories/mock_contribution_repository.dart';
import '../features/progress/progress_store_scope.dart';
import '../features/progress/repositories/progress_store.dart';
import '../features/progress/repositories/shared_preferences_progress_store.dart';
import '../l10n/app_localizations.dart';
import 'main_navigation_screen.dart';
import '../features/attempts/attempt_repository_scope.dart';
import '../features/attempts/repositories/attempt_repository.dart';
import '../features/attempts/repositories/mock_attempt_repository.dart';

class StudyHubApp extends StatefulWidget {
  const StudyHubApp({
    super.key,
    this.learningRepository = const MockLearningRepository(),
    this.contributionRepository = const MockContributionRepository(),
    this.initialLocaleSelection,
    this.localePreferenceStore = const LocalePreferenceStore(),
    this.progressStore,
    this.attemptRepository,
  });

  final LearningRepository learningRepository;
  final ContributionRepository contributionRepository;
  final AppLocaleSelection? initialLocaleSelection;
  final LocalePreferenceStore localePreferenceStore;
  final ProgressStore? progressStore;
  final AttemptRepository? attemptRepository;

  @override
  State<StudyHubApp> createState() => _StudyHubAppState();
}

class _StudyHubAppState extends State<StudyHubApp> {
  late AppLocaleSelection _localeSelection;
  bool _localeSelectedInSession = false;
  late ProgressStore _progressStore;
  late bool _ownsProgressStore;
  late AttemptRepository _attemptRepository;
  late bool _ownsAttemptRepository;

  @override
  void initState() {
    super.initState();
    _localeSelection =
        widget.initialLocaleSelection ?? AppLocaleSelection.system;
    _ownsProgressStore = widget.progressStore == null;
    _progressStore = widget.progressStore ?? SharedPreferencesProgressStore();
    _ownsAttemptRepository = widget.attemptRepository == null;
    _attemptRepository = widget.attemptRepository ?? MockAttemptRepository();
    if (widget.initialLocaleSelection == null) {
      unawaited(_loadStoredLocale());
    }
  }

  @override
  void didUpdateWidget(covariant StudyHubApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (identical(oldWidget.progressStore, widget.progressStore)) {
      _updateAttemptRepository(oldWidget);
      return;
    }
    if (_ownsProgressStore) {
      _progressStore.dispose();
    }
    _ownsProgressStore = widget.progressStore == null;
    _progressStore = widget.progressStore ?? SharedPreferencesProgressStore();
    _updateAttemptRepository(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: _localeSelection.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: AttemptRepositoryScope(
        repository: _attemptRepository,
        child: ProgressStoreScope(
          progressStore: _progressStore,
          child: MainNavigationScreen(
            learningRepository: widget.learningRepository,
            contributionRepository: widget.contributionRepository,
            localeSelection: _localeSelection,
            onLocaleSelected: _selectLocale,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_ownsProgressStore) {
      _progressStore.dispose();
    }
    if (_ownsAttemptRepository) {
      _attemptRepository.dispose();
    }
    super.dispose();
  }

  void _updateAttemptRepository(StudyHubApp oldWidget) {
    if (identical(oldWidget.attemptRepository, widget.attemptRepository)) {
      return;
    }
    if (_ownsAttemptRepository) {
      _attemptRepository.dispose();
    }
    _ownsAttemptRepository = widget.attemptRepository == null;
    _attemptRepository = widget.attemptRepository ?? MockAttemptRepository();
  }

  Future<void> _loadStoredLocale() async {
    final storedLocale = await widget.localePreferenceStore.load();
    if (!mounted ||
        _localeSelectedInSession ||
        storedLocale == _localeSelection) {
      return;
    }
    setState(() => _localeSelection = storedLocale);
  }

  void _selectLocale(AppLocaleSelection selection) {
    _localeSelectedInSession = true;
    if (selection == _localeSelection) {
      unawaited(widget.localePreferenceStore.save(selection));
      return;
    }
    setState(() => _localeSelection = selection);
    unawaited(widget.localePreferenceStore.save(selection));
  }
}
