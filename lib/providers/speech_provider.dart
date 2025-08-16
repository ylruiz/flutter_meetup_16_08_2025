import 'package:riverpod/riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechState {
  const SpeechState({
    this.available = false,
    this.isListening = false,
    this.text = '',
    this.localeId,
    this.austrianizeEnabled = true,
  });

  final bool available;
  final bool isListening;
  final String text;
  final String? localeId;
  final bool austrianizeEnabled;

  SpeechState copyWith({
    bool? available,
    bool? isListening,
    String? text,
    String? localeId,
    bool? austrianizeEnabled,
  }) => SpeechState(
    available: available ?? this.available,
    isListening: isListening ?? this.isListening,
    text: text ?? this.text,
    localeId: localeId ?? this.localeId,
    austrianizeEnabled: austrianizeEnabled ?? this.austrianizeEnabled,
  );
}

final speechControllerProvider =
    StateNotifierProvider<SpeechController, SpeechState>((ref) {
      final controller = SpeechController();
      ref.onDispose(controller.dispose);
      return controller;
    });

class SpeechController extends StateNotifier<SpeechState> {
  SpeechController() : super(const SpeechState());

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _disposed = false;

  Future<void> init() async {
    if (_disposed) return;
    if (state.available) return;

    final available = await _speech.initialize(
      onStatus: (status) {
        if (_disposed) return;
        if (status.contains('notListening')) {
          state = state.copyWith(isListening: false);
        }
      },
      onError: (error) {
        if (_disposed) return;
        state = state.copyWith(isListening: false);
      },
    );

    String? germanLocale;
    try {
      final locales = await _speech.locales();
      germanLocale = _firstOrNull(
        locales
            .where((l) => l.localeId.toLowerCase().startsWith('de'))
            .map((l) => l.localeId),
      );
      germanLocale ??= _firstOrNull(
        locales
            .where((l) => l.localeId.toLowerCase().contains('de'))
            .map((l) => l.localeId),
      );
    } catch (_) {}

    stt.LocaleName? systemLocale;
    try {
      systemLocale = await _speech.systemLocale();
    } catch (_) {}

    if (_disposed) return;
    state = state.copyWith(
      available: available,
      localeId: germanLocale ?? systemLocale?.localeId,
    );
  }

  Future<void> toggle() async {
    if (_disposed) return;

    if (!state.available) {
      await init();
      if (!state.available) return;
    }

    if (state.isListening) {
      await _speech.stop();
      if (_disposed) return;
      state = state.copyWith(isListening: false);
      return;
    }

    await _speech.listen(
      onResult: (result) {
        if (_disposed) return;
        var text = result.recognizedWords;
        if (state.austrianizeEnabled) {
          text = _austrianize(text, state.localeId);
        }
        state = state.copyWith(text: text);
      },
      pauseFor: const Duration(seconds: 3),
      listenFor: const Duration(minutes: 1),
      // partialResults: true, // deprecated
      // cancelOnError: true,  // deprecated
      // listenMode: stt.ListenMode.dictation, // deprecated
      localeId: state.localeId,
    );

    if (_disposed) return;
    state = state.copyWith(isListening: true);
  }

  void setAustrianizeEnabled(bool value) {
    if (_disposed) return;
    state = state.copyWith(austrianizeEnabled: value);
  }

  @override
  void dispose() {
    _disposed = true;
    _speech.cancel();
    super.dispose();
  }

  String _austrianize(String input, String? localeId) {
    final loc = (localeId ?? '').toLowerCase();
    final isGerman = loc.startsWith('de');
    if (!isGerman) return input;

    final replacements = <RegExp, String>{
      // phrases first (longer forms before single words)
      RegExp(r'\bguten\s+(morgen|tag|abend)\b', caseSensitive: false):
          'Grüß Gott',
      RegExp(r'\bguten\s+appetit\b', caseSensitive: false): 'Mahlzeit',
      RegExp(r'\bsehr\s+gut\b', caseSensitive: false): 'ur leiwand',
      RegExp(r'\bja eh\b', caseSensitive: false): 'jo eh',
      RegExp(r'\bkein problem\b', caseSensitive: false): 'passt scho',
      RegExp(r'\balles gut\b', caseSensitive: false): 'passt scho',
      RegExp(r'\bist in ordnung\b', caseSensitive: false): 'passt',
      RegExp(r'\bauf wiedersehen\b', caseSensitive: false): 'Pfiat di',
      RegExp(r'\bgehen wir\b', caseSensitive: false): 'gemma',
      RegExp(r'\bwir gehen\b', caseSensitive: false): 'gemma',
      RegExp(r'\bapfelsaftschorle\b', caseSensitive: false):
          'Apfelsaft gespritzt',
      RegExp(r'\bapfelschorle\b', caseSensitive: false): 'Apfelsaft gespritzt',
      RegExp(r'\bkartoffel\s*salat\b', caseSensitive: false): 'Erdäpfelsalat',
      RegExp(r'\bkartoffel(püree|brei)\b', caseSensitive: false):
          'Erdäpfelpüree',
      RegExp(r'\bvielen dank\b', caseSensitive: false): 'merci',
      RegExp(r'\bdanke schön\b', caseSensitive: false): 'merci',
      RegExp(r'\bdankeschön\b', caseSensitive: false): 'merci',
      RegExp(r'\bentschuldigung\b', caseSensitive: false): 'Tschuldigung',

      // slang/particles
      RegExp(r'\balter\b', caseSensitive: false): 'oida',
      RegExp(r'\balder\b', caseSensitive: false): 'oida',
      RegExp(r'\balda\b', caseSensitive: false): 'oida',
      RegExp(r'\bolda\b', caseSensitive: false): 'oida',
      RegExp(r'\beida\b', caseSensitive: false): 'oida',
      RegExp(r'\beuda\b', caseSensitive: false): 'oida',
      RegExp(r'\boidah\b', caseSensitive: false): 'oida',
      RegExp(r'\boder\b', caseSensitive: false): 'oda',
      RegExp(r'\beben\b', caseSensitive: false): 'eh',
      RegExp(r'\bja\b', caseSensitive: false): 'jo',
      RegExp(r'\bhey\b', caseSensitive: false): 'heast',
      RegExp(r'\bhallo\b', caseSensitive: false): 'Servus',
      RegExp(r'\bhi\b', caseSensitive: false): 'Servus',
      RegExp(r'\btschüss\b', caseSensitive: false): 'Baba',
      RegExp(r'\btschuess\b', caseSensitive: false): 'Baba',
      RegExp(r'\btschau\b', caseSensitive: false): 'Baba',
      RegExp(r'\bciao\b', caseSensitive: false): 'Baba',
      RegExp(r'\bsehr\b', caseSensitive: false): 'ur',
      RegExp(r'\bnicht mehr\b', caseSensitive: false): 'nimma',
      RegExp(r'\bnicht\b', caseSensitive: false): 'ned',
      RegExp(r'\bein bisschen\b', caseSensitive: false): 'a bissl',
      RegExp(r'\bbisschen\b', caseSensitive: false): 'bissl',
      RegExp(r'\bviel\b', caseSensitive: false): 'vü',
      RegExp(r'\bganz\b', caseSensitive: false): 'gaunz',
      RegExp(r'\bwas\b', caseSensitive: false): 'wos',
      RegExp(r'\bwer\b', caseSensitive: false): 'wea',
      RegExp(r'\bwerden\b', caseSensitive: false): 'wean',
      RegExp(r'\bweil\b', caseSensitive: false): 'weu',
      RegExp(r'\bkomm\b', caseSensitive: false): 'kumm',
      RegExp(r'\bgeil\b', caseSensitive: false): 'leiwand',

      // Austrian vocab (food, household, etc.)
      RegExp(r'\bhähnchen\b', caseSensitive: false): 'Hendl',
      RegExp(r'\bbrötchen\b', caseSensitive: false): 'Semmel',
      RegExp(r'\bschrippe\b', caseSensitive: false): 'Semmel',
      RegExp(r'\beinkaufs?tüte\b', caseSensitive: false): 'Einkaufssackerl',
      RegExp(r'\btüte\b', caseSensitive: false): 'Sackerl',
      RegExp(r'\bkartoffel(n)?\b', caseSensitive: false): 'Erdäpfel',
      RegExp(r'\btomate(n)?\b', caseSensitive: false): 'Paradeiser',
      RegExp(r'\baprikose(n)?\b', caseSensitive: false): 'Marillen',
      RegExp(r'\bquark\b', caseSensitive: false): 'Topfen',
      RegExp(r'\bquarkkuchen\b', caseSensitive: false): 'Topfentorte',
      RegExp(r'\btomatenmark\b', caseSensitive: false): 'Paradeismark',
      RegExp(r'\bkartoffelchips\b', caseSensitive: false): 'Erdäpfelchips',
      RegExp(r'\bschlagsahne\b', caseSensitive: false): 'Schlagobers',
      RegExp(r'\bsahne\b', caseSensitive: false): 'Obers',
      RegExp(r'\bblumenkohl\b', caseSensitive: false): 'Karfiol',
      RegExp(r'\baubergine(n)?\b', caseSensitive: false): 'Melanzani',
      RegExp(r'\bmais\b', caseSensitive: false): 'Kukuruz',
      RegExp(r'\bhackfleisch\b', caseSensitive: false): 'Faschiertes',
      RegExp(r'\bpfannkuchen\b', caseSensitive: false): 'Palatschinken',
      RegExp(r'\beierkuchen\b', caseSensitive: false): 'Palatschinken',
      RegExp(r'\bpflaume(n)?\b', caseSensitive: false): 'Zwetschke',
      RegExp(r'\bpilz(e)?\b', caseSensitive: false): 'Schwammerl',
      RegExp(r'\bmädchen\b', caseSensitive: false): 'Mädl',
      RegExp(r'\bmaedchen\b', caseSensitive: false): 'Mädl',
      RegExp(r'\bjunge\b', caseSensitive: false): 'Bua',
      RegExp(r'\bfreund(e)?\b', caseSensitive: false): 'Hawara',
      RegExp(r'\bmülleimer\b', caseSensitive: false): 'Mistkübel',
      RegExp(r'\bmüll\b', caseSensitive: false): 'Mist',
      RegExp(r'\bkühlschrank\b', caseSensitive: false): 'Eiskasten',
      RegExp(r'\bfahrrad\b', caseSensitive: false): 'Radl',
      RegExp(r'\baufzug\b', caseSensitive: false): 'Lift',
      RegExp(r'\bfahrstuhl\b', caseSensitive: false): 'Lift',
      RegExp(r'\btreppenhaus\b', caseSensitive: false): 'Stiegenhaus',
      RegExp(r'\btreppe\b', caseSensitive: false): 'Stiege',
      RegExp(r'\bbürgersteig\b', caseSensitive: false): 'Gehsteig',
      RegExp(r'\bgehweg\b', caseSensitive: false): 'Gehsteig',
      RegExp(r'\berdgeschoss\b', caseSensitive: false): 'Parterre',
      RegExp(r'\bkissen\b', caseSensitive: false): 'Polster',
      RegExp(r'\bettlaken\b', caseSensitive: false): 'Leintuch',
      RegExp(r'\bsofa\b', caseSensitive: false): 'Couch',

      // common phrases
      RegExp(r'\bnatürlich\b', caseSensitive: false): 'eh klar',
      RegExp(r'\bokay\b', caseSensitive: false): 'passt',
      RegExp(r'\bist gut\b', caseSensitive: false): 'passt',
      RegExp(r'\bcool\b', caseSensitive: false): 'leiwand',
    };

    var out = input;
    replacements.forEach((re, v) {
      out = out.replaceAllMapped(re, (m) {
        final match = m.group(0) ?? '';
        if (match.isNotEmpty && match[0].toUpperCase() == match[0]) {
          return v.isNotEmpty ? (v[0].toUpperCase() + v.substring(1)) : v;
        }
        return v;
      });
    });
    return out;
  }
}

T? _firstOrNull<T>(Iterable<T> items) => items.isEmpty ? null : items.first;
