import 'package:flutter/material.dart';

import '../../../core/widgets/studyhub_ui.dart';
import '../../../l10n/app_localizations_x.dart';
import '../../learning/models/question_set.dart';
import '../../learning/models/subject.dart';
import '../../learning/models/topic.dart';
import '../../learning/repositories/learning_repository.dart';
import '../../learning/screens/question_set_detail_screen.dart';
import '../bookmark_scope.dart';

class SavedQuestionSetsScreen extends StatefulWidget {
  const SavedQuestionSetsScreen({super.key, required this.learningRepository});

  final LearningRepository learningRepository;

  @override
  State<SavedQuestionSetsScreen> createState() =>
      _SavedQuestionSetsScreenState();
}

class _SavedQuestionSetsScreenState extends State<SavedQuestionSetsScreen> {
  late Future<List<QuestionSet>> _items;
  final Set<String> _removingIds = {};
  String? _openingId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _items = BookmarkScope.of(context).listBookmarks();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.savedQuestionSets)),
    body: FutureBuilder<List<QuestionSet>>(
      future: _items,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return StudyHubStateView(
            icon: Icons.cloud_off_outlined,
            title: context.l10n.savedLoadError,
            message: context.l10n.checkConnectionBody,
            tone: StudyHubStateTone.error,
            action: FilledButton.icon(
              onPressed: _reload,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.l10n.tryAgain),
            ),
          );
        }
        final items = snapshot.data ?? const <QuestionSet>[];
        if (items.isEmpty) {
          return StudyHubStateView(
            icon: Icons.bookmark_border_rounded,
            title: context.l10n.savedEmpty,
            message: context.l10n.savedEmptyBody,
          );
        }
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                final removing = _removingIds.contains(item.id);
                final opening = _openingId == item.id;
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.bookmark_rounded),
                    title: Text(item.title),
                    subtitle: Text(
                      context.l10n.questionCount(item.questionCount),
                    ),
                    onTap: removing || _openingId != null
                        ? null
                        : () => _openQuestionSet(item),
                    trailing: IconButton(
                      tooltip: context.l10n.removeFromSaved,
                      onPressed: removing || opening
                          ? null
                          : () => _remove(item),
                      icon: removing || opening
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.bookmark_remove_outlined),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    ),
  );

  void _reload() =>
      setState(() => _items = BookmarkScope.of(context).listBookmarks());

  Future<void> _remove(QuestionSet item) async {
    setState(() => _removingIds.add(item.id));
    try {
      await BookmarkScope.of(context).remove(item.id);
      if (mounted) _reload();
    } catch (_) {
      if (mounted) _showError(context.l10n.savedActionError);
    } finally {
      if (mounted) setState(() => _removingIds.remove(item.id));
    }
  }

  Future<void> _openQuestionSet(QuestionSet item) async {
    setState(() => _openingId = item.id);
    try {
      final subjects = await widget.learningRepository.getSubjects();
      final subject = _findSubject(subjects, item.subjectId);
      if (subject == null) throw StateError('Saved subject is unavailable.');
      final topics = await widget.learningRepository.getTopicsBySubjectId(
        item.subjectId,
      );
      final topic = item.topicId == null
          ? null
          : _findTopic(topics, item.topicId!);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => QuestionSetDetailScreen(
            subject: subject,
            topic: topic,
            questionSet: item,
            learningRepository: widget.learningRepository,
          ),
        ),
      );
    } catch (_) {
      if (mounted) _showError(context.l10n.savedOpenError);
    } finally {
      if (mounted) setState(() => _openingId = null);
    }
  }

  Subject? _findSubject(List<Subject> subjects, String id) {
    for (final subject in subjects) {
      if (subject.id == id) return subject;
    }
    return null;
  }

  Topic? _findTopic(List<Topic> topics, String id) {
    for (final topic in topics) {
      if (topic.id == id) return topic;
    }
    return null;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
