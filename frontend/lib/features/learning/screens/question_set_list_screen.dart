import 'package:flutter/material.dart';

import '../data/mock_learning_data.dart';
import '../models/question_set.dart';
import '../models/subject.dart';
import '../models/topic.dart';
import 'question_set_detail_screen.dart';

class QuestionSetListScreen extends StatelessWidget {
  const QuestionSetListScreen({super.key, required this.subject});

  final Subject subject;

  @override
  Widget build(BuildContext context) {
    final questionSets = getQuestionSetsBySubjectId(subject.id);
    final topics = getTopicsBySubjectId(subject.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Question Sets')),
      body: SafeArea(
        child: questionSets.isEmpty
            ? _EmptyQuestionSets(subjectName: subject.name)
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: questionSets.length + 1,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _QuestionSetListHeader(subjectName: subject.name);
                  }

                  final questionSet = questionSets[index - 1];
                  final topic = _findTopic(topics, questionSet.topicId);

                  return _QuestionSetCard(
                    key: ValueKey(questionSet.id),
                    questionSet: questionSet,
                    topic: topic,
                    onTap: () => _openQuestionSet(context, questionSet, topic),
                  );
                },
              ),
      ),
    );
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
          subject: subject,
          questionSet: questionSet,
          topic: topic,
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
                if (topic != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    topic!.name,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(
                      Icons.help_outline,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${questionSet.questionCount} questions',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
