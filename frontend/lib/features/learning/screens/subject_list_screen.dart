import 'package:flutter/material.dart';

import '../../../core/app_design_tokens.dart';
import '../../../core/widgets/studyhub_ui.dart';
import '../../../l10n/app_localizations_x.dart';
import '../models/subject.dart';
import '../repositories/learning_repository.dart';
import '../widgets/learning_state_view.dart';
import 'question_set_list_screen.dart';

class SubjectListScreen extends StatefulWidget {
  const SubjectListScreen({super.key, required this.learningRepository});

  final LearningRepository learningRepository;

  @override
  State<SubjectListScreen> createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends State<SubjectListScreen> {
  late Future<List<Subject>> _subjectsFuture;

  @override
  void initState() {
    super.initState();
    _subjectsFuture = widget.learningRepository.getSubjects();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.browseSubjectsTitle)),
      body: SafeArea(
        child: FutureBuilder<List<Subject>>(
          future: _subjectsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return LearningLoadingState(message: l10n.loadingSubjects);
            }

            if (snapshot.hasError) {
              return LearningErrorState(
                title: l10n.subjectsLoadErrorTitle,
                message: l10n.connectionRetryMessage,
                onRetry: _retryLoadingSubjects,
              );
            }

            final subjects = snapshot.data ?? const <Subject>[];
            if (subjects.isEmpty) {
              return LearningEmptyState(
                icon: Icons.school_outlined,
                title: l10n.noSubjectsTitle,
                message: l10n.noSubjectsMessage,
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.sm,
                AppSpacing.screenHorizontal,
                AppSpacing.screenBottom,
              ),
              itemCount: subjects.length + 1,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const _SubjectListHeader();
                }

                final subject = subjects[index - 1];
                return _SubjectCard(
                  subject: subject,
                  onTap: () => _openSubject(context, subject),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _retryLoadingSubjects() {
    setState(() {
      _subjectsFuture = widget.learningRepository.getSubjects();
    });
  }

  void _openSubject(BuildContext context, Subject subject) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => QuestionSetListScreen(
          subject: subject,
          learningRepository: widget.learningRepository,
        ),
      ),
    );
  }
}

class _SubjectListHeader extends StatelessWidget {
  const _SubjectListHeader();

  @override
  Widget build(BuildContext context) {
    return StudyHubPageHeader(
      icon: Icons.menu_book_outlined,
      title: context.l10n.chooseSubjectTitle,
      body: context.l10n.chooseSubjectSubtitle,
    );
  }
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({required this.subject, required this.onTap});

  final Subject subject;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final metadata = _buildMetadata(context, subject);

    return Semantics(
      button: true,
      label: l10n.openSubjectSemantics(subject.name),
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: theme.colorScheme.surface,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadii.control),
                  ),
                  child: Icon(
                    _subjectIcon(subject),
                    color: theme.colorScheme.primary,
                    size: AppIconSizes.feature,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (subject.description != null) ...[
                        const SizedBox(height: 5),
                        Text(
                          subject.description!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      if (metadata != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          metadata,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _buildMetadata(BuildContext context, Subject subject) {
    final l10n = context.l10n;
    final parts = <String>[];

    if (subject.school != null) {
      parts.add(l10n.schoolMetadata(subject.school!));
    }
    if (subject.program != null) {
      parts.add(l10n.programMetadata(subject.program!));
    }
    if (subject.major != null) {
      parts.add(l10n.majorMetadata(subject.major!));
    }

    return parts.isEmpty ? null : parts.join(' | ');
  }

  IconData _subjectIcon(Subject subject) {
    final value = '${subject.id} ${subject.name}'.toLowerCase();
    if (value.contains('database') || value.contains('data')) {
      return Icons.storage_outlined;
    }
    if (value.contains('javascript') || value.contains('code')) {
      return Icons.code_rounded;
    }
    if (value.contains('java') || value.contains('oop')) {
      return Icons.account_tree_outlined;
    }
    return Icons.menu_book_outlined;
  }
}
