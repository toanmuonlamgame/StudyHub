import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/features/learning/models/paginated_result.dart';
import 'package:frontend/features/learning/models/question_set.dart';
import 'package:frontend/features/learning/models/subject.dart';
import 'package:frontend/features/learning/repositories/mock_learning_repository.dart';
import 'package:frontend/features/learning/screens/question_set_list_screen.dart';
import 'package:frontend/l10n/app_localizations.dart';

const _subject = Subject(id: 'subject_javascript', name: 'JavaScript Basics');

void main() {
  testWidgets('debounces repository search and clearing restores the list', (
    WidgetTester tester,
  ) async {
    final repository = _TrackingSearchRepository();
    await _pumpQuestionSets(tester, repository);

    await tester.enterText(
      find.byKey(const ValueKey('question-set-search-field')),
      'functions',
    );
    await tester.pump(const Duration(milliseconds: 399));
    expect(repository.queries, hasLength(1));

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();
    expect(repository.queries.last, 'functions');
    expect(repository.subjectIds.last, _subject.id);
    expect(repository.cursors.last, isNull);
    expect(find.text('JavaScript Functions'), findsOneWidget);
    expect(find.text('JavaScript Basics Check'), findsNothing);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    expect(repository.queries.last, isNull);
    expect(find.text('JavaScript Basics Check'), findsOneWidget);
  });

  testWidgets('shows a clearable no-results search state', (
    WidgetTester tester,
  ) async {
    await _pumpQuestionSets(tester, const MockLearningRepository());

    await tester.enterText(
      find.byKey(const ValueKey('question-set-search-field')),
      'not available',
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text('No matching question sets'), findsOneWidget);
    expect(find.text('Clear search'), findsOneWidget);
  });

  testWidgets('retries the current search after an error', (
    WidgetTester tester,
  ) async {
    final repository = _SearchErrorRepository();
    await _pumpQuestionSets(tester, repository);

    await tester.enterText(
      find.byKey(const ValueKey('question-set-search-field')),
      'functions',
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('Search could not be completed'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('JavaScript Functions'), findsOneWidget);
    expect(repository.searchCalls, 2);
  });

  testWidgets('ignores stale search results', (WidgetTester tester) async {
    final repository = _StaleSearchRepository();
    await _pumpQuestionSets(tester, repository);

    final field = find.byKey(const ValueKey('question-set-search-field'));
    await tester.enterText(field, 'slow');
    await tester.pump(const Duration(milliseconds: 400));

    await tester.enterText(field, 'functions');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('JavaScript Functions'), findsOneWidget);

    repository.completeSlowSearch();
    await tester.pumpAndSettle();
    expect(find.text('JavaScript Functions'), findsOneWidget);
    expect(find.text('JavaScript Basics Check'), findsNothing);
  });

  testWidgets('topic choice keeps filtering in the repository', (
    WidgetTester tester,
  ) async {
    final repository = _TrackingSearchRepository();
    await _pumpQuestionSets(tester, repository);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Functions'));
    await tester.pumpAndSettle();

    expect(repository.topicIds.last, 'topic_js_functions');
    expect(find.text('JavaScript Functions'), findsOneWidget);
    expect(find.text('JavaScript Basics Check'), findsNothing);
  });

  testWidgets('load more appends without duplicates and stops at the end', (
    WidgetTester tester,
  ) async {
    final repository = _PagingRepository();
    await _pumpQuestionSets(tester, repository);

    expect(find.text('First page set'), findsOneWidget);
    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();

    expect(find.text('First page set'), findsOneWidget);
    expect(find.text('Second page set'), findsOneWidget);
    expect(find.text('Load more'), findsNothing);
    expect(repository.pageCalls, 2);
  });

  testWidgets('load-more retry preserves existing items', (
    WidgetTester tester,
  ) async {
    final repository = _PagingRepository(failNextPageOnce: true);
    await _pumpQuestionSets(tester, repository);

    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();
    expect(find.text('First page set'), findsOneWidget);
    expect(
      find.text('More question sets could not be loaded.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('First page set'), findsOneWidget);
    expect(find.text('Second page set'), findsOneWidget);
  });

  testWidgets('Vietnamese search fits a compact screen with larger text', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await _pumpQuestionSets(
      tester,
      const MockLearningRepository(),
      locale: const Locale('vi'),
    );

    expect(find.text('Tìm theo tên bộ câu hỏi'), findsOneWidget);
    expect(find.text('Tất cả chủ đề'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpQuestionSets(
  WidgetTester tester,
  MockLearningRepository repository, {
  Locale locale = const Locale('en'),
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: QuestionSetListScreen(
        subject: _subject,
        learningRepository: repository,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _TrackingSearchRepository extends MockLearningRepository {
  final List<String?> queries = [];
  final List<String?> subjectIds = [];
  final List<String?> topicIds = [];
  final List<String?> cursors = [];

  @override
  Future<PaginatedResult<QuestionSet>> listQuestionSets({
    String? subjectId,
    String? topicId,
    String? q,
    int limit = 20,
    String? cursor,
  }) {
    queries.add(q);
    subjectIds.add(subjectId);
    topicIds.add(topicId);
    cursors.add(cursor);
    return super.listQuestionSets(
      subjectId: subjectId,
      topicId: topicId,
      q: q,
      limit: limit,
      cursor: cursor,
    );
  }
}

class _StaleSearchRepository extends MockLearningRepository {
  final Completer<PaginatedResult<QuestionSet>> _slowSearch = Completer();

  @override
  Future<PaginatedResult<QuestionSet>> listQuestionSets({
    String? subjectId,
    String? topicId,
    String? q,
    int limit = 20,
    String? cursor,
  }) {
    if (q == 'slow') {
      return _slowSearch.future;
    }
    return super.listQuestionSets(
      subjectId: subjectId,
      topicId: topicId,
      q: q,
      limit: limit,
      cursor: cursor,
    );
  }

  void completeSlowSearch() {
    _slowSearch.complete(
      const PaginatedResult(
        items: [_PagingRepository.first],
        nextCursor: null,
        hasMore: false,
      ),
    );
  }
}

class _SearchErrorRepository extends MockLearningRepository {
  int searchCalls = 0;

  @override
  Future<PaginatedResult<QuestionSet>> listQuestionSets({
    String? subjectId,
    String? topicId,
    String? q,
    int limit = 20,
    String? cursor,
  }) {
    if (q == 'functions') {
      searchCalls++;
      if (searchCalls == 1) {
        return Future.error(StateError('Temporary search failure'));
      }
    }
    return super.listQuestionSets(
      subjectId: subjectId,
      topicId: topicId,
      q: q,
      limit: limit,
      cursor: cursor,
    );
  }
}

class _PagingRepository extends MockLearningRepository {
  _PagingRepository({this.failNextPageOnce = false});

  static const first = QuestionSet(
    id: 'first',
    subjectId: 'subject_javascript',
    title: 'First page set',
    description: 'First page description',
    questionCount: 3,
  );
  static const second = QuestionSet(
    id: 'second',
    subjectId: 'subject_javascript',
    title: 'Second page set',
    description: 'Second page description',
    questionCount: 3,
  );

  bool failNextPageOnce;
  int pageCalls = 0;

  @override
  Future<PaginatedResult<QuestionSet>> listQuestionSets({
    String? subjectId,
    String? topicId,
    String? q,
    int limit = 20,
    String? cursor,
  }) async {
    pageCalls++;
    if (cursor == null) {
      return const PaginatedResult(
        items: [first],
        nextCursor: 'next-page',
        hasMore: true,
      );
    }
    if (failNextPageOnce) {
      failNextPageOnce = false;
      throw StateError('Temporary next-page failure');
    }
    return const PaginatedResult(
      items: [first, second],
      nextCursor: null,
      hasMore: false,
    );
  }
}
