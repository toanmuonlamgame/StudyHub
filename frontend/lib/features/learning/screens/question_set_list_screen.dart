import 'package:flutter/material.dart';

import '../models/question_set.dart';
import '../models/subject.dart';
import '../models/topic.dart';
import '../repositories/learning_repository.dart';
import '../widgets/learning_stat_chip.dart';
import 'question_set_detail_screen.dart';

class QuestionSetListScreen extends StatefulWidget {
  const QuestionSetListScreen({
    super.key,
    required this.subject,
    required this.learningRepository,
  });

  final Subject subject;
  final LearningRepository learningRepository;

  @override
  State<QuestionSetListScreen> createState() => _QuestionSetListScreenState();
}

class _QuestionSetListScreenState extends State<QuestionSetListScreen> {
  late Future<_QuestionSetListData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Question sets')),
      body: SafeArea(
        child: FutureBuilder<_QuestionSetListData>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _QuestionSetLoadError(onRetry: _retryLoadingData);
            }

            final data = snapshot.data;
            if (data == null || data.questionSets.isEmpty) {
              return _EmptyQuestionSets(subjectName: widget.subject.name);
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              itemCount: data.questionSets.length + 1,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _QuestionSetListHeader(
                    subjectName: widget.subject.name,
                  );
                }

                final questionSet = data.questionSets[index - 1];
                final topic = _findTopic(data.topics, questionSet.topicId);

                return _QuestionSetCard(
                  key: ValueKey(questionSet.id),
                  questionSet: questionSet,
                  topic: topic,
                  onTap: () => _openQuestionSet(context, questionSet, topic),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<_QuestionSetListData> _loadData() async {
    final questionSetPage = await widget.learningRepository.listQuestionSets(
      subjectId: widget.subject.id,
      limit: 20,
    );
    final topics = await widget.learningRepository.getTopicsBySubjectId(
      widget.subject.id,
    );

    return _QuestionSetListData(
      questionSets: questionSetPage.items,
      topics: topics,
    );
  }

  void _retryLoadingData() {
    setState(() {
      _dataFuture = _loadData();
    });
  }

  Topic? _findTopic(List<Topic> topics, String? topicId) {
    if (topicId == null) {
      return null;
    }

    for (final topic in topics) {
      if (topic.id == topicId) {
        return topic;
      }
    }

    return null;
  }

  void _openQuestionSet(
    BuildContext context,
    QuestionSet questionSet,
    Topic? topic,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => QuestionSetDetailScreen(
          subject: widget.subject,
          questionSet: questionSet,
          topic: topic,
          learningRepository: widget.learningRepository,
        ),
      ),
    );
  }
}

class _QuestionSetListData {
  const _QuestionSetListData({
    required this.questionSets,
    required this.topics,
  });

  final List<QuestionSet> questionSets;
  final List<Topic> topics;
}

class _QuestionSetLoadError extends StatelessWidget {
  const _QuestionSetLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Question sets could not be loaded.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionSetListHeader extends StatelessWidget {
  const _QuestionSetListHeader({required this.subjectName});

  final String subjectName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subjectName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose a question set to review its details.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionSetCard extends StatelessWidget {
  const _QuestionSetCard({
    super.key,
    required this.questionSet,
    required this.topic,
    required this.onTap,
  });

  final QuestionSet questionSet;
  final Topic? topic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final estimatedMinutes =
        questionSet.estimatedMinutes ??
        (questionSet.questionCount * 1.5).ceil();
    final difficulty = questionSet.difficulty ?? 'easy';

    return Semantics(
      button: true,
      label: 'Open ${questionSet.title}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: theme.colorScheme.surface,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  questionSet.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  questionSet.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    LearningStatChip(
                      icon: Icons.help_outline,
                      label: '${questionSet.questionCount} questions',
                    ),
                    LearningStatChip(
                      icon: Icons.schedule_outlined,
                      label: '$estimatedMinutes min',
                    ),
                    LearningStatChip(
                      icon: Icons.signal_cellular_alt,
                      label: _capitalize(difficulty),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (topic != null)
                      Expanded(
                        child: Text(
                          topic!.name,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      )
                    else
                      const Spacer(),
                    Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}

class _EmptyQuestionSets extends StatelessWidget {
  const _EmptyQuestionSets({required this.subjectName});

  final String subjectName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'No question sets are available for $subjectName yet.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
