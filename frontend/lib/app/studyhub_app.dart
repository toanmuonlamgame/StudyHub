import 'dart:async';

import 'package:flutter/material.dart';

import '../core/app_locale.dart';
import '../core/app_theme.dart';
import '../core/locale_preference_store.dart';
import '../features/learning/repositories/learning_repository.dart';
import '../features/learning/repositories/mock_learning_repository.dart';
import '../features/contribution/repositories/contribution_repository.dart';
import '../features/contribution/repositories/mock_contribution_repository.dart';
import '../features/auth/auth_controller.dart';
import '../features/auth/auth_scope.dart';
import '../features/auth/auth_session_store.dart';
import '../features/auth/repositories/auth_repository.dart';
import '../features/auth/screens/auth_screen.dart';
import '../features/saved/bookmark_scope.dart';
import '../features/saved/repositories/bookmark_repository.dart';
import '../features/saved/repositories/mock_bookmark_repository.dart';
import '../features/progress/progress_store_scope.dart';
import '../features/progress/repositories/progress_store.dart';
import '../features/progress/repositories/shared_preferences_progress_store.dart';
import '../l10n/app_localizations.dart';
import 'app_navigation.dart';
import 'main_navigation_screen.dart';
import '../features/attempts/attempt_repository_scope.dart';
import '../features/attempts/repositories/attempt_repository.dart';
import '../features/attempts/repositories/mock_attempt_repository.dart';
import '../core/device_permissions/device_permission_service.dart';
import '../features/media/media_repository_scope.dart';
import '../features/media/repositories/media_repository.dart';
import '../features/media/repositories/mock_media_repository.dart';
import '../features/notifications/controllers/study_reminder_controller.dart';
import '../features/notifications/repositories/shared_preferences_study_reminder_store.dart';
import '../features/notifications/repositories/study_reminder_store.dart';
import '../features/notifications/services/local_study_notification_service.dart';
import '../features/notifications/services/study_notification_service.dart';
import '../features/notifications/study_reminder_scope.dart';

class StudyHubApp extends StatefulWidget {
  const StudyHubApp({
    super.key,
    this.learningRepository = const MockLearningRepository(),
    this.contributionRepository,
    this.authRepository,
    this.authSessionStore = const AuthSessionStore(),
    this.bookmarkRepository,
    this.initialLocaleSelection,
    this.localePreferenceStore = const LocalePreferenceStore(),
    this.progressStore,
    this.attemptRepository,
    this.mediaRepository = const MockMediaRepository(),
    this.studyReminderStore = const SharedPreferencesStudyReminderStore(),
    this.notificationService,
    this.permissionService = const PlatformDevicePermissionService(),
  });

  final LearningRepository learningRepository;
  final ContributionRepository? contributionRepository;
  final AuthRepository? authRepository;
  final AuthSessionStore authSessionStore;
  final BookmarkRepository? bookmarkRepository;
  final AppLocaleSelection? initialLocaleSelection;
  final LocalePreferenceStore localePreferenceStore;
  final ProgressStore? progressStore;
  final AttemptRepository? attemptRepository;
  final MediaRepository mediaRepository;
  final StudyReminderStore studyReminderStore;
  final StudyNotificationService? notificationService;
  final DevicePermissionService permissionService;

  @override
  State<StudyHubApp> createState() => _StudyHubAppState();
}

class _StudyHubAppState extends State<StudyHubApp> with WidgetsBindingObserver {
  late AppLocaleSelection _localeSelection;
  bool _localeSelectedInSession = false;
  late ProgressStore _progressStore;
  late bool _ownsProgressStore;
  late AttemptRepository _attemptRepository;
  late bool _ownsAttemptRepository;
  late ContributionRepository _contributionRepository;
  late BookmarkRepository _bookmarkRepository;
  late bool _ownsBookmarkRepository;
  AuthController? _authController;
  final AppNavigationController _navigationController =
      AppNavigationController();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late StudyNotificationService _notificationService;
  late StudyReminderController _reminderController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _notificationService =
        widget.notificationService ?? LocalStudyNotificationService();
    _reminderController = StudyReminderController(
      store: widget.studyReminderStore,
      notifications: _notificationService,
      permissions: widget.permissionService,
    );
    unawaited(_initializeReminders());
    _localeSelection =
        widget.initialLocaleSelection ?? AppLocaleSelection.system;
    _ownsProgressStore = widget.progressStore == null;
    _progressStore = widget.progressStore ?? SharedPreferencesProgressStore();
    _ownsAttemptRepository = widget.attemptRepository == null;
    _attemptRepository = widget.attemptRepository ?? MockAttemptRepository();
    _contributionRepository =
        widget.contributionRepository ?? MockContributionRepository();
    _ownsBookmarkRepository = widget.bookmarkRepository == null;
    _bookmarkRepository = widget.bookmarkRepository ?? MockBookmarkRepository();
    if (widget.authRepository != null) {
      _authController = AuthController(
        repository: widget.authRepository!,
        store: widget.authSessionStore,
      );
      unawaited(_authController!.restore());
    }
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
    final app = MediaRepositoryScope(
      repository: widget.mediaRepository,
      child: StudyReminderScope(
        controller: _reminderController,
        child: AttemptRepositoryScope(
          repository: _attemptRepository,
          child: BookmarkScope(
            repository: _bookmarkRepository,
            child: ProgressStoreScope(
              progressStore: _progressStore,
              child: AppNavigationScope(
                controller: _navigationController,
                child: MaterialApp(
                  navigatorKey: _navigatorKey,
                  title: 'StudyHub',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.light,
                  locale: _localeSelection.locale,
                  supportedLocales: AppLocalizations.supportedLocales,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  home: _buildHome(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final controller = _authController;
    return controller == null
        ? app
        : AuthScope(controller: controller, child: app);
  }

  Widget _buildHome() {
    final controller = _authController;
    if (controller == null) return _buildMainNavigation();
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (controller.loading && !controller.isAuthenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return controller.isAuthenticated
            ? _buildMainNavigation()
            : AuthScreen(controller: controller);
      },
    );
  }

  Widget _buildMainNavigation() => MainNavigationScreen(
    navigationController: _navigationController,
    learningRepository: widget.learningRepository,
    contributionRepository: _contributionRepository,
    localeSelection: _localeSelection,
    onLocaleSelected: _selectLocale,
  );

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_ownsProgressStore) {
      _progressStore.dispose();
    }
    if (_ownsAttemptRepository) {
      _attemptRepository.dispose();
    }
    if (_ownsBookmarkRepository) _bookmarkRepository.dispose();
    _authController?.dispose();
    _navigationController.dispose();
    _reminderController.dispose();
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

  Future<void> _initializeReminders() async {
    try {
      final launchPayload = await _notificationService.initialize(
        _handleNotificationTap,
      );
      await _reminderController.load();
      if (launchPayload != null) _handleNotificationTap(launchPayload);
    } catch (_) {
      // Notifications are optional and never block app startup.
    }
  }

  void _handleNotificationTap(String payload) {
    _navigationController.selectTab(0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigatorKey.currentState?.popUntil((route) => route.isFirst);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_reminderController.refreshPermission());
    }
  }
}
