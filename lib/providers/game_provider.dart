import 'package:riverpod/riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/game_models.dart';

// Default demo questions live here so UI stays stateless
final defaultQuestionsProvider = Provider<List<Question>>(
  (ref) => const [
    Question(
      audioPath: 'tts:Wie heißt du?',
      answers: [
        Answer(text: 'Wie geht\'s?', isCorrect: false),
        Answer(text: 'What\'s your name?', isCorrect: true),
        Answer(text: 'Good morning', isCorrect: false),
        Answer(text: 'Goodbye', isCorrect: false),
      ],
    ),
    Question(
      audioPath: 'tts:Könn ma bitte zoin?',
      answers: [
        Answer(text: 'Can we please pay?', isCorrect: true),
        Answer(text: 'Where is the toilet?', isCorrect: false),
        Answer(text: 'Cheers!', isCorrect: false),
        Answer(text: 'Thank you', isCorrect: false),
      ],
    ),
  ],
);

class GameState {
  final List<Question> questions;
  final int currentIndex;
  final int? selectedIdx;
  final bool answered;
  final List<bool?> results;
  final bool finished;

  GameState({
    required this.questions,
    this.currentIndex = 0,
    this.selectedIdx,
    this.answered = false,
    List<bool?>? results,
    this.finished = false,
  }) : results =
           results ??
           List<bool?>.filled(questions.length, null, growable: false);

  Question get current => questions[currentIndex];
  double get progress =>
      questions.isEmpty ? 0 : (currentIndex / questions.length).clamp(0, 1);

  GameState copyWith({
    List<Question>? questions,
    int? currentIndex,
    int? selectedIdx,
    bool? answered,
    List<bool?>? results,
    bool? finished,
  }) => GameState(
    questions: questions ?? this.questions,
    currentIndex: currentIndex ?? this.currentIndex,
    selectedIdx: selectedIdx ?? this.selectedIdx,
    answered: answered ?? this.answered,
    results: results ?? this.results,
    finished: finished ?? this.finished,
  );
}

class GameController extends StateNotifier<GameState> {
  GameController(List<Question> questions)
    : _tts = FlutterTts(),
      super(GameState(questions: questions)) {
    _configureTts();
  }

  final FlutterTts _tts;

  void _configureTts() {
    _tts
      ..setLanguage('de-DE')
      ..setSpeechRate(0.45)
      ..setVolume(1.0)
      ..setPitch(1.0);
  }

  Future<void> playCurrent() async {
    final q = state.current;
    // Support tts:TEXT for now; add assets/urls later
    if (q.audioPath.startsWith('tts:')) {
      final text = q.audioPath.substring(4);
      await _tts.stop();
      await _tts.speak(text);
    }
  }

  void reset(List<Question> questions) {
    state = GameState(questions: questions);
  }

  void select(int idx) {
    if (state.answered || state.finished) return;
    final isCorrect = state.current.answers[idx].isCorrect;
    final newResults = List<bool?>.from(state.results);
    newResults[state.currentIndex] = isCorrect;
    state = state.copyWith(
      selectedIdx: idx,
      answered: true,
      results: newResults,
    );
  }

  void next() {
    if (state.finished) return;
    if (state.currentIndex + 1 < state.questions.length) {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        selectedIdx: null,
        answered: false,
      );
    } else {
      state = state.copyWith(finished: true);
    }
  }

  void selectAndNext(int idx) {
    select(idx);
    next();
  }

  void restart() {
    state = GameState(questions: state.questions);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}

final gameControllerProvider =
    StateNotifierProvider.family<GameController, GameState, List<Question>>(
      (ref, questions) => GameController(questions),
    );

// Non-family default controller using defaultQuestionsProvider
final gameControllerDefaultProvider =
    StateNotifierProvider<GameController, GameState>((ref) {
      final qs = ref.watch(defaultQuestionsProvider);
      return GameController(qs);
    });
