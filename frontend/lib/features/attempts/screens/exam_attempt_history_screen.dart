import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/app_design_tokens.dart';
import '../../../l10n/app_localizations_x.dart';
import '../../learning/screens/quiz_result_screen.dart';
import '../models/exam_attempt.dart';
import '../repositories/attempt_repository.dart';

class ExamAttemptHistoryScreen extends StatefulWidget {
  const ExamAttemptHistoryScreen({
    super.key,
    required this.repository,
    required this.onStartLearning,
  });

  final AttemptRepository repository;
  final VoidCallback onStartLearning;

  @override
  State<ExamAttemptHistoryScreen> createState() =>
      _ExamAttemptHistoryScreenState();
}

class _ExamAttemptHistoryScreenState extends State<ExamAttemptHistoryScreen> {
  late Future<List<ExamAttemptSummary>> _attemptsFuture;

  @override
  void initState() {
    super.initState();
    _attemptsFuture = _loadAttempts();
    widget.repository.addListener(_reload);
  }

  @override
  void didUpdateWidget(covariant ExamAttemptHistoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (identical(oldWidget.repository, widget.repository)) return;
    oldWidget.repository.removeListener(_reload);
    widget.repository.addListener(_reload);
    _reload();
  }

  @override
  void dispose() {
    widget.repository.removeListener(_reload);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.attemptHistory)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: FutureBuilder<List<ExamAttemptSummary>>(
              future: _attemptsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return _HistoryError(onRetry: _reload);
                }
                final attempts = snapshot.data ?? const [];
                if (attempts.isEmpty) {
                  return _HistoryEmpty(onStartLearning: widget.onStartLearning);
                }
                return _AttemptList(attempts: attempts, onOpen: _openAttempt);
              },
            ),
          ),
        ),
      ),
    );
  }

  void _reload() {
    if (!mounted) return;
    final nextAttempts = _loadAttempts();
    setState(() {
      _attemptsFuture = nextAttempts;
    });
  }

  Future<List<ExamAttemptSummary>> _loadAttempts() async {
    return widget.repository.listExamAttempts();
  }

  void _openAttempt(ExamAttemptSummary attempt) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ExamAttemptDetailScreen(
          repository: widget.repository,
          attemptId: attempt.id,
        ),
      ),
    );
  }
}

class ExamAttemptDetailScreen extends StatefulWidget {
  const ExamAttemptDetailScreen({
    super.key,
    required this.repository,
    required this.attemptId,
  });

  final AttemptRepository repository;
  final String attemptId;

  @override
  State<ExamAttemptDetailScreen> createState() =>
      _ExamAttemptDetailScreenState();
}

class _ExamAttemptDetailScreenState extends State<ExamAttemptDetailScreen> {
  late Future<ExamAttemptDetail?> _attemptFuture;

  @override
  void initState() {
    super.initState();
    _attemptFuture = widget.repository.getExamAttempt(widget.attemptId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ExamAttemptDetail?>(
      future: _attemptFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: SafeArea(child: Center(child: CircularProgressIndicator())),
          );
        }
        final attempt = snapshot.data;
        if (snapshot.hasError || attempt == null) {
          return Scaffold(
            appBar: AppBar(title: Text(context.l10n.attemptHistory)),
            body: _HistoryError(
              onRetry: () => setState(
                () => _attemptFuture = widget.repository.getExamAttempt(
                  widget.attemptId,
                ),
              ),
            ),
          );
        }
        return QuizResultScreen(
          result: attempt.result,
          recordLocalProgress: false,
        );
      },
    );
  }
}

class _AttemptList extends StatelessWidget {
  const _AttemptList({required this.attempts, required this.onOpen});

  final List<ExamAttemptSummary> attempts;
  final ValueChanged<ExamAttemptSummary> onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dateFormat = DateFormat.yMMMd(locale).add_jm();
    final percentageFormat = NumberFormat.percentPattern(locale);
    return ListView.separated(
      key: const ValueKey('attempt-history-list'),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.section,
      ),
      itemCount: attempts.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              l10n.attemptHistoryLocalIdentity,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }
        final attempt = attempts[index - 1];
        return Card(
          child: InkWell(
            key: ValueKey('attempt-${attempt.id}'),
            borderRadius: BorderRadius.circular(AppRadii.card),
            onTap: () => onOpen(attempt),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  const Icon(Icons.assignment_turned_in_outlined),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          attempt.questionSetTitle,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          l10n.attemptCorrectSummary(
                            attempt.correctAnswers,
                            attempt.totalQuestions,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${l10n.completed}: ${dateFormat.format(attempt.completedAt.toLocal())}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    percentageFormat.format(attempt.percentageScore / 100),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HistoryEmpty extends StatelessWidget {
  const _HistoryEmpty({required this.onStartLearning});

  final VoidCallback onStartLearning;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history_toggle_off, size: 56),
            const SizedBox(height: 16),
            Text(
              context.l10n.noAttemptsYet,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(context.l10n.tryYourFirstExam, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onStartLearning,
              icon: const Icon(Icons.menu_book_outlined),
              label: Text(context.l10n.startLearning),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryError extends StatelessWidget {
  const _HistoryError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 52),
            const SizedBox(height: 12),
            Text(context.l10n.unableToLoadHistory, textAlign: TextAlign.center),
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
