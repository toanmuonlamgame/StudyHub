import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../core/app_motion.dart';
import '../../l10n/app_localizations_x.dart';

part 'word_challenge_screen.dart';

class StudyWord {
  const StudyWord(this.english, this.vietnamese);

  final String english;
  final String vietnamese;

  bool accepts(String input) => input.trim().toLowerCase() == english;
}

const studyWords = [
  StudyWord('apple', 'quả táo'),
  StudyWord('cat', 'con mèo'),
  StudyWord('book', 'quyển sách'),
  StudyWord('bird', 'con chim'),
  StudyWord('sun', 'mặt trời'),
  StudyWord('water', 'nước'),
  StudyWord('tree', 'cây'),
  StudyWord('house', 'ngôi nhà'),
];

class WordGamesScreen extends StatelessWidget {
  const WordGamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _GamePage(
      title: l10n.englishGames,
      children: [
        _GameChoice(
          icon: Icons.style_outlined,
          title: l10n.wordMatch,
          description: l10n.wordMatchSubtitle,
          color: Theme.of(context).colorScheme.tertiaryContainer,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const WordMatchScreen()),
          ),
        ),
        const SizedBox(height: 12),
        _GameChoice(
          icon: Icons.rocket_launch_outlined,
          title: l10n.wordShip,
          description: l10n.wordShipSubtitle,
          color: Theme.of(context).colorScheme.secondaryContainer,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const WordShipScreen()),
          ),
        ),
        const SizedBox(height: 12),
        for (final (mode, icon, title, description, color) in [
          (
            WordChallengeMode.sentence,
            Icons.segment_rounded,
            l10n.gameSentence,
            l10n.gameSentenceSubtitle,
            Theme.of(context).colorScheme.primaryContainer,
          ),
          (
            WordChallengeMode.spelling,
            Icons.spellcheck_rounded,
            l10n.gameSpelling,
            l10n.gameSpellingSubtitle,
            Theme.of(context).colorScheme.tertiaryContainer,
          ),
          (
            WordChallengeMode.listening,
            Icons.headphones_outlined,
            l10n.gameListening,
            l10n.gameListeningSubtitle,
            Theme.of(context).colorScheme.secondaryContainer,
          ),
        ]) ...[
          _GameChoice(
            icon: icon,
            title: title,
            description: description,
            color: color,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => WordChallengeScreen(mode: mode),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _GameChoice extends StatelessWidget {
  const _GameChoice({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class WordShipScreen extends StatefulWidget {
  const WordShipScreen({super.key, this.words = studyWords});

  final List<StudyWord> words;

  @override
  State<WordShipScreen> createState() => _WordShipScreenState();
}

class _WordShipScreenState extends State<WordShipScreen> {
  final _input = TextEditingController();
  final _missed = <StudyWord>{};
  List<StudyWord> get _wordBank =>
      widget.words.isEmpty ? studyWords : widget.words;
  late List<StudyWord> _round = _wordBank;
  int _index = 0;
  int _score = 0;
  bool _wrong = false;
  bool _hit = false;
  bool _skipped = false;

  void _fire(String answer) {
    if (_hit || _skipped || answer.trim().isEmpty) return;
    final word = _round[_index];
    setState(() {
      if (word.accepts(answer)) {
        _hit = true;
        if (!_missed.contains(word)) _score++;
      } else {
        _wrong = true;
        _missed.add(word);
        _input.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _input.text.length,
        );
      }
    });
  }

  void _next() {
    _input.clear();
    setState(() {
      _index++;
      _wrong = _hit = _skipped = false;
    });
  }

  void _restart(List<StudyWord> words) {
    _input.clear();
    setState(() {
      _round = words;
      _missed.clear();
      _index = _score = 0;
      _wrong = _hit = _skipped = false;
    });
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final finished = _index == _round.length;
    final locked = _hit || _skipped;
    return _GamePage(
      title: l10n.wordShip,
      step: _index,
      footer: locked
          ? _GameAdvance(
              message: _skipped
                  ? l10n.gameAnswer(_round[_index].english)
                  : l10n.gameHit,
              label: l10n.gameNext,
              onPressed: _next,
            )
          : null,
      children: finished
          ? [
              _RoundResult(
                score: _score,
                total: _round.length,
                missed: _missed,
                replay: () => _restart(_wordBank),
                retry: () => _restart(_missed.toList()),
              ),
            ]
          : [
              _RoundProgress(done: _index, total: _round.length),
              const SizedBox(height: 16),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFF153B3A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 72,
                        child: AnimatedSwitcher(
                          duration: AppMotion.duration(
                            context,
                            const Duration(milliseconds: 180),
                          ),
                          child: Icon(
                            _hit ? Icons.auto_awesome : Icons.rocket_launch,
                            key: ValueKey(_hit),
                            size: 56,
                            color: _hit
                                ? const Color(0xFFFFD987)
                                : const Color(0xFFBAF0D8),
                          ),
                        ),
                      ),
                      Text(
                        _round[_index].vietnamese,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (!locked) ...[
                if (_wrong) ...[
                  _GameFeedback(message: l10n.gameTryAgain),
                  const SizedBox(height: 8),
                ],
                TextField(
                  controller: _input,
                  autocorrect: false,
                  enableSuggestions: false,
                  textInputAction: TextInputAction.done,
                  onSubmitted: _fire,
                  decoration: InputDecoration(labelText: l10n.gameWordInput),
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _input,
                  builder: (_, value, _) => FilledButton.icon(
                    onPressed: value.text.trim().isEmpty
                        ? null
                        : () => _fire(value.text),
                    icon: const Icon(Icons.bolt),
                    label: Text(l10n.gameFire),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    setState(() {
                      _missed.add(_round[_index]);
                      _skipped = true;
                    });
                  },
                  child: Text(l10n.gameSkip),
                ),
              ],
            ],
    );
  }
}

typedef _WordCard = ({StudyWord word, bool isEnglish});

class WordMatchScreen extends StatefulWidget {
  const WordMatchScreen({super.key, this.words = studyWords});

  final List<StudyWord> words;

  @override
  State<WordMatchScreen> createState() => _WordMatchScreenState();
}

class _WordMatchScreenState extends State<WordMatchScreen> {
  final _matched = <StudyWord>{};
  final _missed = <StudyWord>{};
  final _flipped = <int>[];
  late List<StudyWord> _round;
  late List<_WordCard> _cards;
  bool? _lastMatched;

  @override
  void initState() {
    super.initState();
    _prepare(widget.words);
  }

  void _prepare(List<StudyWord> words) {
    final bank = words.isEmpty ? studyWords : words;
    _round = (bank.toList()..shuffle()).take(4).toList();
    _cards = [
      for (final word in _round) ...[
        (word: word, isEnglish: true),
        (word: word, isEnglish: false),
      ],
    ]..shuffle();
    _matched.clear();
    _missed.clear();
    _flipped.clear();
    _lastMatched = null;
  }

  void _flip(int index) {
    if (_flipped.length == 2 ||
        _flipped.contains(index) ||
        _matched.contains(_cards[index].word)) {
      return;
    }
    setState(() {
      _lastMatched = null;
      _flipped.add(index);
      if (_flipped.length == 2) {
        final first = _cards[_flipped.first].word;
        final second = _cards[index].word;
        _lastMatched = first == second;
        if (_lastMatched == true) {
          _matched.add(first);
          _flipped.clear();
        } else {
          _missed.addAll([first, second]);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    return _GamePage(
      title: l10n.wordMatch,
      step: _matched.length == _round.length ? 'result' : 'board',
      footer: _flipped.length == 2
          ? _GameAdvance(
              message: l10n.gameNotAPair,
              label: l10n.gameContinue,
              onPressed: () => setState(() {
                _flipped.clear();
                _lastMatched = null;
              }),
            )
          : null,
      children: _matched.length == _round.length
          ? [
              _RoundResult(
                score: _round.length - _missed.length,
                total: _round.length,
                missed: _missed,
                replay: () => setState(() => _prepare(widget.words)),
                retry: () => setState(() => _prepare(_missed.toList())),
              ),
            ]
          : [
              _RoundProgress(done: _matched.length, total: _round.length),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final largeText = MediaQuery.textScalerOf(context).scale(16);
                  final columns = constraints.maxWidth < 280 || largeText > 30
                      ? 1
                      : 2;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisExtent: 48 + largeText * 2.5,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: _cards.length,
                    itemBuilder: (context, index) {
                      final card = _cards[index];
                      final matched = _matched.contains(card.word);
                      final revealed = matched || _flipped.contains(index);
                      final label = card.isEnglish
                          ? card.word.english
                          : card.word.vietnamese;
                      return OutlinedButton(
                        key: ValueKey('word-card-${card.isEnglish}-$label'),
                        onPressed: revealed || _flipped.length == 2
                            ? null
                            : () => _flip(index),
                        style: OutlinedButton.styleFrom(
                          disabledForegroundColor: colors.onSurface,
                          backgroundColor: colors.primaryContainer,
                          disabledBackgroundColor: matched
                              ? colors.secondaryContainer
                              : colors.surfaceContainerHighest,
                          padding: const EdgeInsets.all(8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: revealed
                            ? Text(
                                matched ? '✓ $label' : label,
                                textAlign: TextAlign.center,
                              )
                            : Semantics(
                                label: l10n.gameFlipped(index + 1),
                                child: const Icon(Icons.question_mark_rounded),
                              ),
                      );
                    },
                  );
                },
              ),
              if (_lastMatched == true) ...[
                const SizedBox(height: 12),
                _GameFeedback(message: l10n.gamePair),
              ],
            ],
    );
  }
}

class _RoundProgress extends StatelessWidget {
  const _RoundProgress({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$done / $total'),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: done / total),
      ],
    );
  }
}

class _RoundResult extends StatelessWidget {
  const _RoundResult({
    required this.score,
    required this.total,
    required this.missed,
    required this.replay,
    required this.retry,
    this.reviewLabel,
  });

  final int score;
  final int total;
  final Set<StudyWord> missed;
  final VoidCallback replay;
  final VoidCallback retry;
  final String? reviewLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.emoji_events_outlined,
          size: 48,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 12),
        Text(
          l10n.gameDone,
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        Text(l10n.gameScore(score, total), textAlign: TextAlign.center),
        const SizedBox(height: 20),
        if (missed.isNotEmpty) ...[
          FilledButton(
            onPressed: retry,
            child: Text(reviewLabel ?? l10n.gameRetryMissed),
          ),
          const SizedBox(height: 8),
        ],
        OutlinedButton(onPressed: replay, child: Text(l10n.gameReplay)),
        if (missed.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(l10n.gameMissed, style: theme.textTheme.titleMedium),
          for (final word in missed)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(word.english),
              subtitle: Text(word.vietnamese),
            ),
        ],
      ],
    );
  }
}

class _GameFeedback extends StatelessWidget {
  const _GameFeedback({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Text(message, textAlign: TextAlign.center),
  );
}

class _GameAdvance extends StatelessWidget {
  const _GameAdvance({
    required this.message,
    required this.label,
    required this.onPressed,
  });

  final String message;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      _GameFeedback(message: message),
      const SizedBox(height: 8),
      FilledButton(onPressed: onPressed, child: Text(label)),
    ],
  );
}

class _GamePage extends StatelessWidget {
  const _GamePage({
    required this.title,
    required this.children,
    this.step,
    this.footer,
  });

  final String title;
  final List<Widget> children;
  final Object? step;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    key: ValueKey(step),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: children,
                  ),
                ),
                if (footer != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: footer,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
