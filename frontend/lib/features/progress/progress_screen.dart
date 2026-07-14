import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/widgets/studyhub_ui.dart';
import '../../l10n/app_localizations_x.dart';
import 'models/completed_learning_session.dart';
import 'progress_store_scope.dart';
import 'repositories/progress_store.dart';
import 'widgets/progress_widgets.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key, required this.onStartLearning});

  final VoidCallback onStartLearning;

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  ProgressStore? _progressStore;
  late Future<List<CompletedLearningSession>> _sessionsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextStore = ProgressStoreScope.of(context);
    if (identical(nextStore, _progressStore)) {
      return;
    }
    _progressStore?.removeListener(_handleStoreChanged);
    _progressStore = nextStore;
    _progressStore!.addListener(_handleStoreChanged);
    _sessionsFuture = nextStore.loadSessions();
  }

  @override
  void dispose() {
    _progressStore?.removeListener(_handleStoreChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.progressTab)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: FutureBuilder<List<CompletedLearningSession>>(
              future: _sessionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return _ProgressLoadError(onRetry: _reload);
                }
                final sessions = snapshot.data ?? const [];
                if (sessions.isEmpty) {
                  return _ProgressEmptyState(
                    onStartLearning: widget.onStartLearning,
                  );
                }
                return _ProgressHistory(
                  sessions: sessions,
                  onClearHistory: _confirmClearHistory,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _handleStoreChanged() {
    if (mounted) {
      _reload();
    }
  }

  void _reload() {
    setState(() {
      _sessionsFuture = _progressStore!.loadSessions();
    });
  }

  Future<void> _confirmClearHistory() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.progressClearHistoryTitle),
        content: Text(l10n.progressClearHistoryBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.progressCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.progressConfirmClear),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }

    try {
      await _progressStore!.clearHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.progressHistoryCleared)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.progressHistoryClearError)),
        );
      }
    }
  }
}

class _ProgressEmptyState extends StatelessWidget {
  const _ProgressEmptyState({required this.onStartLearning});

  final VoidCallback onStartLearning;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return ListView(
      key: const ValueKey('progress-list'),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      children: [
        StudyHubSectionHeader(
          title: l10n.progressOverview,
          subtitle: l10n.progressLocalOnlyNote,
        ),
        const SizedBox(height: 36),
        Icon(
          Icons.insights_outlined,
          size: 68,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 18),
        Text(
          l10n.progressNoHistoryTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.progressNoHistoryBody,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 22),
        FilledButton.icon(
          key: const ValueKey('progress-start-learning'),
          onPressed: onStartLearning,
          icon: const Icon(Icons.arrow_forward),
          label: Text(l10n.startLearning),
        ),
      ],
    );
  }
}

class _ProgressHistory extends StatelessWidget {
  const _ProgressHistory({
    required this.sessions,
    required this.onClearHistory,
  });

  final List<CompletedLearningSession> sessions;
  final VoidCallback onClearHistory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final percentageFormat = NumberFormat.percentPattern(locale);
    final dateFormat = DateFormat.yMMMd(locale).add_jm();
    final average =
        sessions.fold<double>(
          0,
          (total, session) => total + session.percentage,
        ) /
        sessions.length;
    final uniqueSets = sessions
        .map((session) => session.questionSetId)
        .toSet()
        .length;
    final metrics = [
      (
        Icons.task_alt_outlined,
        l10n.progressCompletedSessions,
        sessions.length.toString(),
      ),
      (
        Icons.track_changes_outlined,
        l10n.progressAverageAccuracy,
        percentageFormat.format(average / 100),
      ),
      (
        Icons.library_books_outlined,
        l10n.progressCompletedQuestionSets,
        uniqueSets.toString(),
      ),
      (
        Icons.schedule_outlined,
        l10n.progressLatestActivity,
        dateFormat.format(sessions.first.completedAt),
      ),
    ];

    return ListView(
      key: const ValueKey('progress-list'),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        StudyHubSectionHeader(
          title: l10n.progressOverview,
          subtitle: l10n.progressLocalOnlyNote,
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final textScale = MediaQuery.textScalerOf(context).scale(1);
            final useSingleColumn = textScale >= 1.3;
            const spacing = 10.0;
            final width = useSingleColumn
                ? constraints.maxWidth
                : (constraints.maxWidth - spacing) / 2;
            return Wrap(
              key: const ValueKey('progress-history'),
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final metric in metrics)
                  SizedBox(
                    width: width,
                    child: ProgressMetricCard(
                      icon: metric.$1,
                      label: metric.$2,
                      value: metric.$3,
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 26),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.progressRecentResults,
                style: theme.textTheme.titleLarge,
              ),
            ),
            IconButton(
              key: const ValueKey('progress-clear-history'),
              onPressed: onClearHistory,
              tooltip: l10n.progressClearHistory,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final session in sessions.take(20)) ...[
          ProgressSessionCard(
            key: ValueKey('progress-session-${session.id}'),
            session: session,
            formattedDate: dateFormat.format(session.completedAt),
            formattedPercentage: percentageFormat.format(
              session.percentage / 100,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ProgressLoadError extends StatelessWidget {
  const _ProgressLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(context.l10n.progressLoadError, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }
}
