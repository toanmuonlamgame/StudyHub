import 'package:flutter/material.dart';

import 'learning/repositories/learning_repository.dart';
import 'learning/screens/subject_list_screen.dart';

class HomePlaceholder extends StatelessWidget {
  const HomePlaceholder({super.key, required this.learningRepository});

  final LearningRepository learningRepository;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.auto_stories_outlined,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('StudyHub', style: theme.textTheme.titleLarge),
                ],
              ),
              const Spacer(flex: 2),
              Text('Learn with focus.', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 12),
              Text(
                'Choose a subject, practise with trusted question sets, and understand every result.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: () => _openSubjects(context),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Start learning'),
              ),
              const Spacer(flex: 3),
              Row(
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 18,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Answers stay hidden until you submit or check.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openSubjects(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) =>
            SubjectListScreen(learningRepository: learningRepository),
      ),
    );
  }
}
