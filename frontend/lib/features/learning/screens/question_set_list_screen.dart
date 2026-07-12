import 'dart:async';

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations_x.dart';
import '../models/question_set.dart';
import '../models/subject.dart';
import '../models/topic.dart';
import '../repositories/learning_repository.dart';
import '../widgets/learning_state_view.dart';
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
  static const _pageSize = 20;
  static const _searchDebounce = Duration(milliseconds: 400);

  final TextEditingController _searchController = TextEditingController();
  final List<QuestionSet> _questionSets = [];
  List<Topic> _topics = const [];
  Timer? _searchTimer;
  String _query = '';
  String? _selectedTopicId;
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
    unawaited(_loadTopics());
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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.questionSetsTitle)),
      body: SafeArea(
        child: Column(
          children: [
            _QuestionSetListHeader(subjectName: widget.subject.name),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
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
                  border: const OutlineInputBorder(),
                ),
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
            : l10n.noQuestionSetsMessage(widget.subject.name),
        actionLabel: searching ? l10n.clearSearch : null,
        onAction: searching ? _clearSearch : null,
      );
    }

    return ListView.separated(
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

  Future<void> _loadTopics() async {
    try {
      final topics = await widget.learningRepository.getTopicsBySubjectId(
        widget.subject.id,
      );
      if (mounted) {
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
        subjectId: widget.subject.id,
        topicId: _selectedTopicId,
        q: _query.isEmpty ? null : _query,
        limit: _pageSize,
      );
      if (!mounted ||
          generation != _requestGeneration ||
          _searchController.text.trim() != _query) {
        return;
      }
      setState(() {
        _questionSets.addAll(_deduplicate(page.items));
        _nextCursor = page.nextCursor;
        _hasMore = page.hasMore && page.nextCursor != null;
        _isInitialLoading = false;
      });
    } catch (_) {
      if (!mounted ||
          generation != _requestGeneration ||
          _searchController.text.trim() != _query) {
        return;
      }
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
        subjectId: widget.subject.id,
        topicId: _selectedTopicId,
        q: _query.isEmpty ? null : _query,
        limit: _pageSize,
        cursor: cursor,
      );
      if (!mounted ||
          generation != _requestGeneration ||
          _searchController.text.trim() != _query) {
        return;
      }
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
      if (!mounted ||
          generation != _requestGeneration ||
          _searchController.text.trim() != _query) {
        return;
      }
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

class _QuestionSetListHeader extends StatelessWidget {
  const _QuestionSetListHeader({required this.subjectName});

  final String subjectName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subjectName, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(
            context.l10n.chooseQuestionSetSubtitle,
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
    final l10n = context.l10n;
    final estimatedMinutes =
        questionSet.estimatedMinutes ??
        (questionSet.questionCount * 1.5).ceil();
    final difficulty = questionSet.difficulty ?? 'easy';

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
                Text(questionSet.title, style: theme.textTheme.titleMedium),
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
