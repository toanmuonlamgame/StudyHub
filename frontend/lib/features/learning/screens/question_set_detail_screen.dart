import 'package:flutter/material.dart';
import 'dart:async';

import '../../../core/device_feedback.dart';
import '../../../l10n/app_localizations_x.dart';
import '../../saved/bookmark_scope.dart';
import '../models/question_set.dart';
import '../models/subject.dart';
import '../models/topic.dart';
import '../repositories/learning_repository.dart';
import '../widgets/learning_stat_chip.dart';
import 'mode_selection_screen.dart';

class QuestionSetDetailScreen extends StatefulWidget {
  const QuestionSetDetailScreen({
    super.key,
    required this.subject,
    required this.questionSet,
    required this.learningRepository,
    this.topic,
  });

  final Subject subject;
  final QuestionSet questionSet;
  final Topic? topic;
  final LearningRepository learningRepository;

  @override
  State<QuestionSetDetailScreen> createState() =>
      _QuestionSetDetailScreenState();
}

class _QuestionSetDetailScreenState extends State<QuestionSetDetailScreen> {
  bool _bookmarked = false;
  bool _bookmarkLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadBookmark();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final estimatedMinutes =
        widget.questionSet.estimatedMinutes ??
        (widget.questionSet.questionCount * 1.5).ceil();
    final difficulty = widget.questionSet.difficulty ?? 'easy';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.questionSetTitle),
        actions: [
          IconButton(
            tooltip: _bookmarked ? l10n.removeFromSaved : l10n.saveForLater,
            onPressed: _bookmarkLoading ? null : _toggleBookmark,
            icon: Icon(
              _bookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Text(
              widget.questionSet.title,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.menu_book_outlined,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    widget.topic == null
                        ? widget.subject.name
                        : '${widget.subject.name} / ${widget.topic!.name}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                LearningStatChip(
                  icon: Icons.help_outline,
                  label: l10n.questionCount(widget.questionSet.questionCount),
                ),
                LearningStatChip(
                  icon: Icons.schedule_outlined,
                  label: l10n.minuteCount(estimatedMinutes),
                ),
                LearningStatChip(
                  icon: Icons.signal_cellular_alt,
                  label: _localizedDifficulty(context, difficulty),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(l10n.aboutQuestionSet, style: theme.textTheme.titleLarge),
            const SizedBox(height: 9),
            Text(
              widget.questionSet.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.45,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.visibility_off_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(l10n.answersHiddenDetail)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            FilledButton.icon(
              onPressed: () => _chooseMode(context),
              icon: const Icon(Icons.arrow_forward),
              label: Text(l10n.chooseLearningMode),
            ),
          ],
        ),
      ),
    );
  }

  void _chooseMode(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ModeSelectionScreen(
          questionSet: widget.questionSet,
          learningRepository: widget.learningRepository,
        ),
      ),
    );
  }

  Future<void> _loadBookmark() async {
    final value = await BookmarkScope.of(
      context,
    ).contains(widget.questionSet.id);
    if (mounted) {
      setState(() {
        _bookmarked = value;
        _bookmarkLoading = false;
      });
    }
  }

  Future<void> _toggleBookmark() async {
    setState(() => _bookmarkLoading = true);
    final repository = BookmarkScope.of(context);
    if (_bookmarked) {
      await repository.remove(widget.questionSet.id);
    } else {
      await repository.save(widget.questionSet);
    }
    if (!mounted) return;
    setState(() {
      _bookmarked = !_bookmarked;
      _bookmarkLoading = false;
    });
    unawaited(DeviceFeedback.selection());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _bookmarked ? context.l10n.savedAdded : context.l10n.savedRemoved,
        ),
      ),
    );
  }

  String _localizedDifficulty(BuildContext context, String value) {
    final l10n = context.l10n;
    return switch (value.toLowerCase()) {
      'medium' => l10n.difficultyMedium,
      'hard' => l10n.difficultyHard,
      _ => l10n.difficultyEasy,
    };
  }
}
