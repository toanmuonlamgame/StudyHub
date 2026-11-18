import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/widgets/study_illustration.dart';
import '../../../l10n/app_localizations_x.dart';
import '../models/question_set.dart';
import '../models/exam_language.dart';
import '../models/subject.dart';
import '../models/topic.dart';
import '../repositories/learning_repository.dart';
import '../widgets/learning_state_view.dart';
import '../widgets/learning_stat_chip.dart';
import 'question_set_detail_screen.dart';

class QuestionSetListScreen extends StatefulWidget {
  const QuestionSetListScreen({
    super.key,
    this.subject,
    this.initialQuery = '',
    required this.learningRepository,
  });

  final Subject? subject;
  final String initialQuery;
  final LearningRepository learningRepository;

  @override
  State<QuestionSetListScreen> createState() => _QuestionSetListScreenState();
}

class _QuestionSetListScreenState extends State<QuestionSetListScreen> {
  static const _pageSize = 20;
  static const _searchDebounce = Duration(milliseconds: 400);

  final TextEditingController _searchController = TextEditingController();
  final List<QuestionSet> _questionSets = [];
  List<Topic> _topics = const [];
  List<Subject> _subjects = const [];
  String? _selectedSubjectId;
  Timer? _searchTimer;
  String _query = '';
  String? _selectedTopicId;
  String? _language;
  String? _nextCursor;
  bool _hasMore = false;
  bool _isInitialLoading = true;
  bool _initialLoadFailed = false;
  bool _isLoadingMore = false;
  bool _loadMoreFailed = false;
  int _requestGeneration = 0;

  @override
  void initState() {
    super.initState();
    _selectedSubjectId = widget.subject?.id;
    _query = widget.initialQuery.trim();
    _searchController.text = _query;
    if (widget.subject == null) {
      unawaited(_loadSubjects());
    } else {
      unawaited(_loadTopics(widget.subject!.id));
    }
    unawaited(_loadFirstPage());
  }

  @override
  void dispose() {
    _requestGeneration++;
    _searchTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.questionSetsTitle)),
      body: SafeArea(
        child: Column(
          children: [
            _QuestionSetListHeader(
              subjectName: widget.subject?.name ?? l10n.questionBank,
              compact: keyboardOpen,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, keyboardOpen ? 8 : 14, 20, 8),
              child: TextField(
                key: const ValueKey('question-set-search-field'),
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onChanged: _onSearchChanged,
                onSubmitted: _submitSearch,
                decoration: InputDecoration(
                  hintText: l10n.searchQuestionSetsHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: l10n.clearSearchTooltip,
                          onPressed: _clearSearch,
                          icon: const Icon(Icons.close),
                        ),
                ),
              ),
            ),
            if (!keyboardOpen && widget.subject == null && _subjects.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 2, 20, 8),
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _selectedSubjectId ?? '',
                  decoration: InputDecoration(
                    labelText: l10n.browseSubjectsTitle,
                  ),
                  items: [
                    DropdownMenuItem(value: '', child: Text(l10n.allSubjects)),
                    for (final subject in _subjects)
                      DropdownMenuItem(
                        value: subject.id,
                        child: Text(
                          subject.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) =>
                      _selectSubject(value == '' ? null : value),
                ),
              ),
            if (_topics.isNotEmpty)
              Semantics(
                label: l10n.topicsLabel,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 10),
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: Text(l10n.allTopics),
                        selected: _selectedTopicId == null,
                        onSelected: (_) => _selectTopic(null),
                      ),
                      for (final topic in _topics) ...[
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text(topic.name),
                          selected: _selectedTopicId == topic.id,
                          onSelected: (_) => _selectTopic(topic.id),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            if (!keyboardOpen)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 2, 20, 8),
                child: DropdownButtonFormField<String>(
                  key: ValueKey(_language),
                  isExpanded: true,
                  initialValue: _language ?? '',
                  decoration: InputDecoration(labelText: l10n.examLanguage),
                  items: [
                    DropdownMenuItem(value: '', child: Text(l10n.allLanguages)),
                    for (final code in examLanguageCodes)
                      DropdownMenuItem(
                        value: code,
                        child: Text(examLanguageLabel(l10n, code)),
                      ),
                  ],
                  onChanged: (value) {
                    _language = value == null || value.isEmpty ? null : value;
                    unawaited(_loadFirstPage());
                  },
                ),
              ),
            Expanded(child: _buildContent(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final l10n = context.l10n;

    if (_isInitialLoading) {
      return LearningLoadingState(
        message: _query.isEmpty
            ? l10n.loadingQuestionSets
            : l10n.searchingQuestionSets,
      );
    }

    if (_initialLoadFailed) {
      return LearningErrorState(
        title: _query.isEmpty
            ? l10n.questionSetsLoadErrorTitle
            : l10n.searchLoadErrorTitle,
        message: l10n.connectionRetryMessage,
        onRetry: _loadFirstPage,
      );
    }

    if (_questionSets.isEmpty) {
      final searching = _query.isNotEmpty;
      return LearningEmptyState(
        icon: searching ? Icons.search_off : Icons.quiz_outlined,
        title: searching ? l10n.noSearchResultsTitle : l10n.noQuestionSetsTitle,
        message: searching
            ? l10n.noSearchResultsMessage
            : l10n.noQuestionSetsMessage(
                widget.subject?.name ?? l10n.questionBank,
              ),
        actionLabel: searching
            ? l10n.clearSearch
            : _language != null
            ? l10n.allLanguages
            : null,
        onAction: searching
            ? _clearSearch
            : _language != null
            ? () {
                _language = null;
                unawaited(_loadFirstPage());
              }
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFirstPage,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        itemCount: _questionSets.length + 1,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == _questionSets.length) {
            return _buildLoadMore(context);
          }

          final questionSet = _questionSets[index];
          final topic = _findTopic(questionSet.topicId);
          return _QuestionSetCard(
            key: ValueKey(questionSet.id),
            questionSet: questionSet,
            topic: topic,
            onTap: () => _openQuestionSet(context, questionSet, topic),
          );
        },
      ),
    );
  }

  Widget _buildLoadMore(BuildContext context) {
    final l10n = context.l10n;

    if (_isLoadingMore) {
      return Semantics(
        liveRegion: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 10),
              Flexible(child: Text(l10n.loadingMore)),
            ],
          ),
        ),
      );
    }

    if (_loadMoreFailed) {
      return Column(
        children: [
          Text(
            l10n.loadMoreError,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _loadMore,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.retryLoadMore),
          ),
        ],
      );
    }

    if (!_hasMore) {
      return const SizedBox.shrink();
    }

    return OutlinedButton.icon(
      onPressed: _loadMore,
      icon: const Icon(Icons.expand_more),
      label: Text(l10n.loadMore),
    );
  }

  Future<void> _loadSubjects() async {
    try {
      final subjects = await widget.learningRepository.getSubjects();
      if (mounted) setState(() => _subjects = subjects);
    } catch (_) {
      // The global search can still show results when subject metadata fails.
    }
  }

  void _selectSubject(String? subjectId) {
    if (subjectId == _selectedSubjectId) return;
    _selectedSubjectId = subjectId;
    _selectedTopicId = null;
    _topics = const [];
    if (subjectId != null) unawaited(_loadTopics(subjectId));
    unawaited(_loadFirstPage());
  }

  Future<void> _loadTopics(String subjectId) async {
    try {
      final topics = await widget.learningRepository.getTopicsBySubjectId(
        subjectId,
      );
      if (mounted && subjectId == _selectedSubjectId) {
        setState(() => _topics = topics);
      }
    } catch (_) {
      // Topic filtering is optional; the question-set list remains usable.
    }
  }

  Future<void> _loadFirstPage() async {
    final generation = ++_requestGeneration;
    setState(() {
      _isInitialLoading = true;
      _initialLoadFailed = false;
      _isLoadingMore = false;
      _loadMoreFailed = false;
      _questionSets.clear();
      _nextCursor = null;
      _hasMore = false;
    });

    try {
      final page = await widget.learningRepository.listQuestionSets(
        subjectId: _selectedSubjectId,
        topicId: _selectedTopicId,
        language: _language,
        q: _query.isEmpty ? null : _query,
        limit: _pageSize,
      );
      // A newer committed query invalidates the response; typing alone does not.
      if (!mounted || generation != _requestGeneration) return;
      setState(() {
        _questionSets.addAll(_deduplicate(page.items));
        _nextCursor = page.nextCursor;
        _hasMore = page.hasMore && page.nextCursor != null;
        _isInitialLoading = false;
      });
    } catch (_) {
      if (!mounted || generation != _requestGeneration) return;
      setState(() {
        _isInitialLoading = false;
        _initialLoadFailed = true;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore || _nextCursor == null) {
      return;
    }

    final generation = _requestGeneration;
    final cursor = _nextCursor;
    setState(() {
      _isLoadingMore = true;
      _loadMoreFailed = false;
    });

    try {
      final page = await widget.learningRepository.listQuestionSets(
        subjectId: _selectedSubjectId,
        topicId: _selectedTopicId,
        language: _language,
        q: _query.isEmpty ? null : _query,
        limit: _pageSize,
        cursor: cursor,
      );
      if (!mounted || generation != _requestGeneration) return;
      setState(() {
        final existingIds = _questionSets.map((item) => item.id).toSet();
        _questionSets.addAll(
          page.items.where((item) => existingIds.add(item.id)),
        );
        _nextCursor = page.nextCursor;
        _hasMore = page.hasMore && page.nextCursor != null;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted || generation != _requestGeneration) return;
      setState(() {
        _isLoadingMore = false;
        _loadMoreFailed = true;
      });
    }
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _searchTimer?.cancel();
    _searchTimer = Timer(_searchDebounce, () => _applySearch(value));
  }

  void _submitSearch(String value) {
    FocusScope.of(context).unfocus();
    _searchTimer?.cancel();
    _applySearch(value);
  }

  void _applySearch(String value) {
    final normalized = value.trim();
    if (normalized == _query) {
      return;
    }
    _query = normalized;
    unawaited(_loadFirstPage());
  }

  void _clearSearch() {
    _searchTimer?.cancel();
    _searchController.clear();
    if (_query.isEmpty) {
      setState(() {});
      return;
    }
    _query = '';
    unawaited(_loadFirstPage());
  }

  void _selectTopic(String? topicId) {
    if (topicId == _selectedTopicId) {
      return;
    }
    _selectedTopicId = topicId;
    unawaited(_loadFirstPage());
  }

  List<QuestionSet> _deduplicate(List<QuestionSet> items) {
    final ids = <String>{};
    return items.where((item) => ids.add(item.id)).toList(growable: false);
  }

  Topic? _findTopic(String? topicId) {
    if (topicId == null) {
      return null;
    }
    for (final topic in _topics) {
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
    final subject =
        widget.subject ??
        _subjects
            .where((subject) => subject.id == questionSet.subjectId)
            .firstOrNull ??
        Subject(id: questionSet.subjectId, name: context.l10n.questionBank);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => QuestionSetDetailScreen(
          subject: subject,
          questionSet: questionSet,
          topic: topic,
          learningRepository: widget.learningRepository,
        ),
      ),
    );
  }
}

class _QuestionSetListHeader extends StatelessWidget {
  const _QuestionSetListHeader({
    required this.subjectName,
    required this.compact,
  });

  final String subjectName;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subjectName,
            style: compact
                ? theme.textTheme.titleMedium
                : theme.textTheme.headlineSmall,
            maxLines: compact ? 1 : null,
            overflow: compact ? TextOverflow.ellipsis : null,
          ),
          if (!compact) ...[
            const SizedBox(height: 6),
            Text(
              context.l10n.chooseQuestionSetSubtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
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
    final l10n = context.l10n;
    final estimatedMinutes =
        questionSet.estimatedMinutes ??
        (questionSet.questionCount * 1.5).ceil();
    final difficulty = questionSet.difficulty ?? 'easy';
    final artwork = artworkForTopic(questionSet.topicId);
    final coverColor = switch (artwork) {
      StudyArtwork.science ||
      StudyArtwork.compass => theme.colorScheme.secondaryContainer,
      StudyArtwork.english => theme.colorScheme.tertiaryContainer,
      _ => theme.colorScheme.primaryContainer,
    };

    return Semantics(
      button: true,
      label: l10n.openQuestionSetSemantics(questionSet.title),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            questionSet.title,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            questionSet.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (MediaQuery.textScalerOf(context).scale(14) <= 21) ...[
                      const SizedBox(width: 12),
                      Container(
                        width: 82,
                        height: 82,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: coverColor,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: StudyIllustration(artwork),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    LearningStatChip(
                      icon: Icons.help_outline,
                      label: l10n.questionCount(questionSet.questionCount),
                    ),
                    LearningStatChip(
                      icon: Icons.schedule_outlined,
                      label: l10n.minuteCount(estimatedMinutes),
                    ),
                    LearningStatChip(
                      icon: Icons.signal_cellular_alt,
                      label: _difficultyLabel(context, difficulty),
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

  String _difficultyLabel(BuildContext context, String value) {
    final l10n = context.l10n;
    return switch (value.toLowerCase()) {
      'medium' => l10n.difficultyMedium,
      'hard' => l10n.difficultyHard,
      _ => l10n.difficultyEasy,
    };
  }
}
