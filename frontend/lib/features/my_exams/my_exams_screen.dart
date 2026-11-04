import 'package:flutter/material.dart';

import '../../app/app_navigation.dart';
import '../../core/app_design_tokens.dart';
import '../../l10n/app_localizations_x.dart';
import '../attempts/attempt_repository_scope.dart';
import '../attempts/screens/exam_attempt_history_screen.dart';
import '../auth/auth_scope.dart';
import '../auth/models/auth_user.dart';
import '../contribution/repositories/contribution_repository.dart';
import '../contribution/screens/contribution_management_screen.dart';
import '../learning/repositories/learning_repository.dart';
import '../profile/widgets/user_avatar.dart';
import '../saved/bookmark_scope.dart';
import '../saved/screens/saved_question_sets_screen.dart';
import 'recent_exam_store.dart';
import 'recent_exams_screen.dart';
import 'exam_collections_screen.dart';

class MyExamsScreen extends StatefulWidget {
  const MyExamsScreen({
    super.key,
    required this.learningRepository,
    required this.contributionRepository,
  });

  final LearningRepository learningRepository;
  final ContributionRepository contributionRepository;

  @override
  State<MyExamsScreen> createState() => _MyExamsScreenState();
}

class _MyExamsScreenState extends State<MyExamsScreen> {
  Future<({int uploaded, int completed, int saved})>? _summary;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _summary ??= _loadSummary();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthScope.maybeOf(context)?.user ?? _demoUser;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.myExams),
          actions: [
            IconButton(
              tooltip: context.l10n.examCollections,
              icon: const Icon(Icons.folder_outlined),
              onPressed: () {
                final navigator = Navigator.of(context);
                final account = AuthScope.maybeOf(context)?.user;
                final key = account == null
                    ? null
                    : '${account.id}.${account.createdAt.toUtc().millisecondsSinceEpoch}';
                navigator.push<void>(
                  MaterialPageRoute(
                    builder: (_) => ExamCollectionsScreen(
                      repository: widget.learningRepository,
                      store: ExamCollectionStore(
                        accountKey: key,
                        session: navigator,
                      ),
                    ),
                  ),
                );
              },
            ),
            IconButton(
              tooltip: context.l10n.recentExams,
              icon: const Icon(Icons.history),
              onPressed: () {
                final navigator = Navigator.of(context);
                final account = AuthScope.maybeOf(context)?.user;
                navigator.push<void>(
                  MaterialPageRoute(
                    builder: (_) => RecentExamsScreen(
                      repository: widget.learningRepository,
                      store: RecentExamStore(account, guestSession: navigator),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.sm,
                  AppSpacing.xl,
                  AppSpacing.md,
                ),
                child: Row(
                  children: [
                    UserAvatar(user: user, radius: 30),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            context.l10n.personalLearningLibrary,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              FutureBuilder<({int uploaded, int completed, int saved})>(
                future: _summary,
                builder: (context, snapshot) {
                  final values = snapshot.data;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: Row(
                      children: [
                        _SummaryMetric(
                          label: context.l10n.uploaded,
                          value: values?.uploaded,
                        ),
                        _SummaryMetric(
                          label: context.l10n.completed,
                          value: values?.completed,
                        ),
                        _SummaryMetric(
                          label: context.l10n.saved,
                          value: values?.saved,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              TabBar(
                tabs: [
                  Tab(text: context.l10n.uploaded),
                  Tab(text: context.l10n.completed),
                  Tab(text: context.l10n.saved),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    ContributionManagementScreen(
                      learningRepository: widget.learningRepository,
                      contributionRepository: widget.contributionRepository,
                      embedded: true,
                    ),
                    ExamAttemptHistoryScreen(
                      repository: AttemptRepositoryScope.of(context),
                      embedded: true,
                      onStartLearning: () =>
                          AppNavigationScope.maybeOf(context)?.selectTab(1),
                    ),
                    SavedQuestionSetsScreen(
                      learningRepository: widget.learningRepository,
                      embedded: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<({int uploaded, int completed, int saved})> _loadSummary() async {
    final values = await Future.wait([
      widget.contributionRepository.listSubmissions(),
      AttemptRepositoryScope.of(context).listExamAttempts(),
      BookmarkScope.of(context).listBookmarks(),
    ]);
    return (
      uploaded: values[0].length,
      completed: values[1].length,
      saved: values[2].length,
    );
  }
}

final _demoUser = AuthUser(
  id: 'demo',
  email: 'demo@studyhub.local',
  displayName: 'StudyHub Learner',
  createdAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
);

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.label, required this.value});

  final String label;
  final int? value;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Semantics(
      label: '$label ${value ?? 0}',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          children: [
            Text(
              value?.toString() ?? '-',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
    ),
  );
}
