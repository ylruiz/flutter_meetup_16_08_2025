import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/phrase_book_item.dart';
import '../network/api_providers.dart';

/// Loads all phrase book items using ApiClient (mocked JSON)
final phraseBookItemsProvider = FutureProvider<List<PhraseBookItem>>((
  ref,
) async {
  final api = ref.read(apiClientProvider);
  return api.fetchPhraseBook();
});

/// Filtered view by category title (e.g., "Greetings", "Food", ...)
final phraseBookByCategoryProvider =
    Provider.family<List<PhraseBookItem>, String>((ref, categoryTitle) {
      final asyncItems = ref.watch(phraseBookItemsProvider);
      return asyncItems.maybeWhen(
        data: (items) => items
            .where((e) => e.category == categoryTitle)
            .toList(growable: false),
        orElse: () => const <PhraseBookItem>[],
      );
    });
