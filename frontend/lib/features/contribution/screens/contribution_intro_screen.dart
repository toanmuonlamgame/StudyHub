import 'package:flutter/material.dart';

import '../../../l10n/app_localizations_x.dart';
import '../../learning/repositories/learning_repository.dart';
import '../models/question_set_draft.dart';
import '../repositories/contribution_repository.dart';
import 'contribution_editor_screen.dart';
import 'contribution_management_screen.dart';
import 'paste_exam_screen.dart';

class ContributionIntroScreen extends StatelessWidget {
  const ContributionIntroScreen({
    super.key,
    required this.learningRepository,
    required this.contributionRepository,
  });

  final LearningRepository learningRepository;
  final ContributionRepository contributionRepository;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.contributionTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Icon(
                  Icons.post_add_rounded,
                  size: 56,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.contributionIntroHeading,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                Text(l10n.contributionIntroBody),
                const SizedBox(height: 24),
                _Guideline(
                  icon: Icons.fact_check_outlined,
                  text: l10n.contributionReviewGuideline,
                ),
                _Guideline(
                  icon: Icons.shield_outlined,
                  text: l10n.contributionSafetyGuideline,
                ),
                _Guideline(
                  icon: Icons.person_off_outlined,
                  text: l10n.contributionLocalGuideline,
                ),
                const SizedBox(height: 28),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ContributionManagementScreen(
                        learningRepository: learningRepository,
                        contributionRepository: contributionRepository,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.folder_copy_outlined),
                  label: Text(l10n.myContributions),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ContributionEditorScreen(
                        learningRepository: learningRepository,
                        contributionRepository: contributionRepository,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.edit_note_rounded),
                  label: Text(l10n.contributionCreateQuickly),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _openPasteFlow(context),
                  icon: const Icon(Icons.content_paste_go_rounded),
                  label: Text(l10n.contributionPasteFullExam),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openPasteFlow(BuildContext context) async {
    final draft = await Navigator.of(context).push<QuestionSetDraft>(
      MaterialPageRoute<QuestionSetDraft>(
        builder: (_) => const PasteExamScreen(baseDraft: QuestionSetDraft()),
      ),
    );
    if (draft == null || !context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ContributionEditorScreen(
          learningRepository: learningRepository,
          contributionRepository: contributionRepository,
          initialDraft: draft,
          startWithQuestions: false,
        ),
      ),
    );
  }
}

class _Guideline extends StatelessWidget {
  const _Guideline({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon),
    title: Text(text),
  );
}
