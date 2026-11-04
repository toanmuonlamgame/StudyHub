import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/word_games/word_games_screen.dart';
import 'package:frontend/l10n/app_localizations.dart';

void main() {
  const apple = StudyWord('apple', 'quả táo');
  const cat = StudyWord('cat', 'con mèo');

  testWidgets('spaceship scores the first try and replays only missed words', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const WordShipScreen(words: [apple, cat])));
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Fire'))
          .onPressed,
      isNull,
    );

    await tester.enterText(find.byType(TextField), 'banana');
    await _tap(tester, 'Fire');
    expect(find.text('Not quite. Try again.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), ' APPLE ');
    await _tap(tester, 'Fire');
    expect(find.text('Direct hit!'), findsOneWidget);
    await _tap(tester, 'Next word');
    await tester.enterText(find.byType(TextField), 'cat');
    await _tap(tester, 'Fire');
    await _tap(tester, 'Next word');

    expect(find.text('Score: 1 / 2'), findsOneWidget);
    expect(find.text('apple'), findsOneWidget);
    expect(find.text('cat'), findsNothing);
    await _tap(tester, 'Review missed words');
    expect(find.text('0 / 1'), findsOneWidget);
    expect(find.text('quả táo'), findsOneWidget);
  });

  testWidgets('matching hides words, clears a mismatch and finishes a round', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 430);
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(_app(const WordMatchScreen(words: [apple, cat])));
    expect(find.text('apple'), findsNothing);
    expect(find.text('quả táo'), findsNothing);

    Future<void> card(String key) async {
      final target = find.byKey(ValueKey(key));
      await tester.ensureVisible(target);
      await tester.tap(target);
      await tester.pumpAndSettle();
    }

    await card('word-card-true-apple');
    await card('word-card-false-con mèo');
    expect(find.text('Not a match. Try a different pair.'), findsOneWidget);
    expect(find.text('Continue').hitTestable(), findsOneWidget);
    await _tap(tester, 'Continue');
    expect(find.text('apple'), findsNothing);

    await card('word-card-true-apple');
    await card('word-card-false-quả táo');
    expect(find.text('You found a pair!'), findsOneWidget);
    await card('word-card-true-cat');
    await card('word-card-false-con mèo');
    expect(find.text('Round complete'), findsOneWidget);
    expect(find.text('Score: 0 / 2'), findsOneWidget);
    expect(find.text('Review missed words').hitTestable(), findsOneWidget);
    await _tap(tester, 'Review missed words');
    expect(find.text('0 / 2'), findsOneWidget);
  });

  testWidgets('Vietnamese menu fits a small phone with large text', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 640);
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      _app(const WordGamesScreen(), locale: const Locale('vi')),
    );
    expect(find.text('Lật thẻ ghép đôi'), findsOneWidget);
    await _tap(tester, 'Phi thuyền từ vựng');
    expect(find.text('Bắn'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sentence order can be corrected before continuing', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(const WordChallengeScreen(mode: WordChallengeMode.sentence)),
    );
    for (final word in ['read', 'I', 'every', 'day.']) {
      await tester.tap(find.widgetWithText(OutlinedButton, word));
      await tester.pump();
    }
    await _tap(tester, 'Check');
    expect(find.text('Try another answer.'), findsOneWidget);
    await _tap(tester, 'Clear');
    for (final word in ['I', 'read', 'every', 'day.']) {
      await tester.tap(find.widgetWithText(OutlinedButton, word));
      await tester.pump();
    }
    await _tap(tester, 'Check');
    expect(find.text("That's right!"), findsOneWidget);
  });

  testWidgets('spelling completes a word and reveals the full form', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(const WordChallengeScreen(mode: WordChallengeMode.spelling)),
    );
    expect(find.text('a p p _ e'), findsOneWidget);
    await _tap(tester, 'l');
    expect(find.text('Answer: apple'), findsOneWidget);
    await _tap(tester, 'Next question');
    expect(find.text('c _ t'), findsOneWidget);
  });

  testWidgets(
    'listening handles missing audio and enables choices after playback',
    (tester) async {
      final spoken = <String>[];
      await tester.pumpWidget(
        _app(
          WordChallengeScreen(
            mode: WordChallengeMode.listening,
            onSpeak: (word) async {
              spoken.add(word);
              return spoken.length > 1;
            },
          ),
        ),
      );
      final choice = find.widgetWithText(OutlinedButton, 'quả táo');
      expect(tester.widget<OutlinedButton>(choice).onPressed, isNull);
      await _tap(tester, 'Play word');
      expect(find.textContaining('No English voice'), findsOneWidget);
      expect(tester.widget<OutlinedButton>(choice).onPressed, isNull);
      await _tap(tester, 'Play word');
      expect(spoken, ['apple', 'apple']);
      expect(find.text('apple'), findsNothing);
      await _tap(tester, 'quả táo');
      expect(find.text('Answer: apple'), findsOneWidget);
    },
  );
}

Widget _app(Widget home, {Locale locale = const Locale('en')}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: locale,
  home: home,
);

Future<void> _tap(WidgetTester tester, String label) async {
  await tester.pump();
  final target = find.text(label);
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}
