part of 'word_games_screen.dart';

enum WordChallengeMode { sentence, spelling, listening }

typedef _Challenge = ({
  StudyWord review,
  String prompt,
  List<String> options,
  String answer,
});

List<_Challenge> _challenges(WordChallengeMode mode) => switch (mode) {
  WordChallengeMode.sentence => [
    for (final (words, meaning) in [
      (['I', 'read', 'every', 'day.'], 'Tôi đọc sách mỗi ngày.'),
      (['The', 'bird', 'can', 'fly.'], 'Con chim có thể bay.'),
      (['This', 'is', 'my', 'book.'], 'Đây là sách của tôi.'),
      (['I', 'drink', 'water', 'daily.'], 'Tôi uống nước mỗi ngày.'),
    ])
      (
        review: StudyWord(words.join(' '), meaning),
        prompt: meaning,
        options: words,
        answer: words.join(' '),
      ),
  ],
  WordChallengeMode.spelling => [
    for (final (wordIndex, pattern, answer, options) in [
      (0, 'a p p _ e', 'l', ['l', 'n', 'r']),
      (1, 'c _ t', 'a', ['a', 'e', 'i']),
      (2, 'b o _ k', 'o', ['o', 'e', 'a']),
      (3, 'b _ r d', 'i', ['i', 'u', 'e']),
      (4, 's _ n', 'u', ['u', 'a', 'i']),
    ])
      (
        review: studyWords[wordIndex],
        prompt: pattern,
        options: options,
        answer: answer,
      ),
  ],
  WordChallengeMode.listening => [
    for (var i = 0; i < studyWords.length; i++)
      (
        review: studyWords[i],
        prompt: studyWords[i].english,
        options: [
          studyWords[i].vietnamese,
          studyWords[(i + 1) % studyWords.length].vietnamese,
          studyWords[(i + 3) % studyWords.length].vietnamese,
        ],
        answer: studyWords[i].vietnamese,
      ),
  ],
};

class WordChallengeScreen extends StatefulWidget {
  const WordChallengeScreen({super.key, required this.mode, this.onSpeak});

  final WordChallengeMode mode;
  final Future<bool> Function(String)? onSpeak;

  @override
  State<WordChallengeScreen> createState() => _WordChallengeScreenState();
}

class _WordChallengeScreenState extends State<WordChallengeScreen> {
  late final _bank = _challenges(widget.mode);
  late var _round = _bank;
  late var _options = _shuffledOptions(_round.first);
  final _missed = <_Challenge>{};
  final _picked = <int>[];
  int _index = 0;
  int _score = 0;
  bool _wrong = false;
  bool _correct = false;
  bool _skipped = false;
  bool _speaking = false;
  bool _heard = false;
  bool _audioError = false;
  FlutterTts? _tts;

  bool get _isSentence => widget.mode == WordChallengeMode.sentence;
  bool get _isListening => widget.mode == WordChallengeMode.listening;
  bool get _locked => _correct || _skipped;

  List<String> _shuffledOptions(_Challenge question) =>
      question.options.toList()..shuffle();

  Future<bool> _speak(String word) async {
    final tts = _tts ??= FlutterTts();
    if (await tts.isLanguageAvailable('en-US') != true) return false;
    await tts.setLanguage('en-US');
    await tts.setSpeechRate(kIsWeb ? 0.85 : 0.42);
    await tts.awaitSpeakCompletion(true);
    if (!mounted || !_speaking) return false;
    final result = await tts.speak(word);
    // The web plugin resolves without a value on a successful speech end.
    return kIsWeb ? result == null : result == 1;
  }

  Future<void> _hear() async {
    if (_speaking || _locked) return;
    final index = _index;
    final word = _round[index].prompt;
    setState(() {
      _speaking = true;
      _audioError = false;
    });
    var played = false;
    try {
      played = await (widget.onSpeak ?? _speak)(
        word,
      ).timeout(const Duration(seconds: 8));
    } catch (_) {
      // Some platforms have no speech engine or English voice installed.
      unawaited(_stopAudio());
    }
    if (!mounted || index != _index || _locked) return;
    setState(() {
      _speaking = false;
      _heard = _heard || played;
      _audioError = !played;
    });
  }

  Future<void> _stopAudio() async {
    try {
      await _tts?.stop();
    } catch (_) {
      // No active audio engine to stop.
    }
  }

  @override
  void dispose() {
    unawaited(_stopAudio());
    super.dispose();
  }

  void _check(String answer) {
    if (_locked || (_isListening && !_heard)) return;
    final current = _round[_index];
    setState(() {
      _correct = answer == current.answer;
      _wrong = !_correct;
      if (!_correct) {
        _missed.add(current);
      } else if (!_missed.contains(current)) {
        _score++;
      }
    });
  }

  void _resetQuestion() {
    _picked.clear();
    _wrong = _correct = _skipped = _speaking = _heard = _audioError = false;
    if (_index < _round.length) {
      _options = _shuffledOptions(_round[_index]);
    }
  }

  void _next() {
    unawaited(_stopAudio());
    setState(() {
      _index++;
      _resetQuestion();
    });
  }

  void _restart(List<_Challenge> questions) {
    setState(() {
      _round = questions;
      _missed.clear();
      _index = _score = 0;
      _resetQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = switch (widget.mode) {
      WordChallengeMode.sentence => l10n.gameSentence,
      WordChallengeMode.spelling => l10n.gameSpelling,
      WordChallengeMode.listening => l10n.gameListening,
    };
    if (_index == _round.length) {
      return _GamePage(
        title: title,
        step: _index,
        children: [
          _RoundResult(
            score: _score,
            total: _round.length,
            missed: _missed.map((item) => item.review).toSet(),
            replay: () => _restart(_bank),
            retry: () => _restart(_missed.toList()),
            reviewLabel: _isSentence ? l10n.gameReviewMissed : null,
          ),
        ],
      );
    }
    final current = _round[_index];
    final theme = Theme.of(context);
    return _GamePage(
      title: title,
      step: _index,
      footer: _locked
          ? _GameAdvance(
              message: !_skipped && _isSentence
                  ? l10n.gameCorrect
                  : l10n.gameAnswer(current.review.english),
              label: l10n.gameNextQuestion,
              onPressed: _next,
            )
          : null,
      children: [
        _RoundProgress(done: _index, total: _round.length),
        const SizedBox(height: 16),
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Icon(
                  _isListening ? Icons.headphones : Icons.edit_note_rounded,
                  size: 36,
                ),
                const SizedBox(height: 10),
                if (_isListening)
                  FilledButton.icon(
                    onPressed: _speaking || _locked ? null : _hear,
                    icon: _speaking
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.volume_up_outlined),
                    label: Text(l10n.gameHear),
                  )
                else ...[
                  Text(
                    current.prompt,
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  if (!_isSentence) Text(current.review.vietnamese),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_audioError) _GameFeedback(message: l10n.gameAudioUnavailable),
        if (_wrong && !_locked) ...[
          _GameFeedback(message: l10n.gameTryDifferent),
          const SizedBox(height: 8),
        ],
        if (_isSentence)
          _sentenceControls(context)
        else
          for (final option in _options)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OutlinedButton(
                onPressed: _locked || (_isListening && (!_heard || _speaking))
                    ? null
                    : () => _check(option),
                child: Text(option),
              ),
            ),
        const SizedBox(height: 8),
        if (!_locked)
          TextButton(
            onPressed: _speaking
                ? null
                : () {
                    unawaited(_stopAudio());
                    setState(() {
                      _missed.add(current);
                      _skipped = true;
                    });
                  },
            child: Text(l10n.gameSkipQuestion),
          ),
      ],
    );
  }

  Widget _sentenceControls(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_picked.isEmpty)
          Text(l10n.gamePickWords)
        else
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final index in _picked)
                InputChip(
                  label: Text(_options[index]),
                  onDeleted: _locked
                      ? null
                      : () => setState(() => _picked.remove(index)),
                ),
            ],
          ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (var index = 0; index < _options.length; index++)
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(48, 48),
                ),
                onPressed: _locked || _picked.contains(index)
                    ? null
                    : () => setState(() => _picked.add(index)),
                child: Text(_options[index]),
              ),
          ],
        ),
        if (!_locked) ...[
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _picked.length != _options.length
                ? null
                : () => _check(_picked.map((i) => _options[i]).join(' ')),
            child: Text(l10n.gameCheck),
          ),
          TextButton(
            onPressed: _picked.isEmpty
                ? null
                : () => setState(() => _picked.clear()),
            child: Text(l10n.gameClear),
          ),
        ],
      ],
    );
  }
}
