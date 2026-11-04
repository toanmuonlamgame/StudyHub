import 'package:flutter/material.dart';

import '../../l10n/app_localizations_x.dart';
import '../learning/models/question_set.dart';
import '../learning/models/subject.dart';
import '../learning/repositories/api_learning_repository.dart';
import '../learning/repositories/learning_repository.dart';
import '../learning/screens/question_set_detail_screen.dart';
import '../learning/widgets/learning_state_view.dart';
import 'recent_exam_store.dart';

class RecentExamsScreen extends StatefulWidget {
  const RecentExamsScreen({
    super.key,
    required this.repository,
    required this.store,
  });

  final LearningRepository repository;
  final RecentExamStore store;

  @override
  State<RecentExamsScreen> createState() => _RecentExamsScreenState();
}

class _RecentExamsScreenState extends State<RecentExamsScreen> {
  late var _results = _load();
  bool _clearing = false;

  Future<List<(QuestionSet, Subject)>> _load() async {
    final ids = await widget.store.load();
    if (ids.isEmpty) return [];
    final subjects = await widget.repository.getSubjects();
    final byId = {for (final subject in subjects) subject.id: subject};
    final sets = await Future.wait(
      ids.map((id) async {
        try {
          return await widget.repository.getQuestionSetById(id);
        } on LearningApiException catch (error) {
          if (error.statusCode == 404) return null;
          rethrow;
        }
      }),
    );
    return [
      for (final set in sets)
        if (set != null)
          if (byId[set.subjectId] case final Subject subject) (set, subject),
    ];
  }

  Future<void> _clear() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearRecentExams),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.progressCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.contributionRemove),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    setState(() => _clearing = true);
    try {
      await widget.store.clear();
      if (mounted) setState(() => _results = _load());
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.connectionRetryMessage)));
      }
    } finally {
      if (mounted) setState(() => _clearing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recentExams),
        actions: [
          IconButton(
            tooltip: l10n.clearRecentExams,
            onPressed: _clearing ? null : _clear,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: FutureBuilder<List<(QuestionSet, Subject)>>(
          future: _results,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return LearningLoadingState(message: l10n.loadingQuestionSets);
            }
            if (snapshot.hasError) {
              return LearningErrorState(
                title: l10n.questionSetsLoadErrorTitle,
                message: l10n.connectionRetryMessage,
                onRetry: () => setState(() => _results = _load()),
              );
            }
            final exams = snapshot.data ?? [];
            if (exams.isEmpty) return Center(child: Text(l10n.noRecentExams));
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: exams.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final (exam, subject) = exams[index];
                    return Card(
                      child: ListTile(
                        title: Text(exam.title),
                        subtitle: Text(subject.name),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          await Navigator.of(context).push<void>(
                            MaterialPageRoute(
                              builder: (_) => QuestionSetDetailScreen(
                                questionSet: exam,
                                subject: subject,
                                learningRepository: widget.repository,
                              ),
                            ),
                          );
                          if (mounted) setState(() => _results = _load());
                        },
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
