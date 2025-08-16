import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../data/category_list.dart';
import '../models/category_item_model.dart';
import '../providers/phrase_book_provider.dart';

class PhraseBookPage extends ConsumerWidget {
  const PhraseBookPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 60, left: 16, right: 16, bottom: 16),
      itemCount: categoryList.length,
      itemBuilder: (context, index) {
        final category = categoryList[index];
        return _PhraseCard(category: category);
      },
    );
  }
}

class _PhraseCard extends ConsumerStatefulWidget {
  final CategoryItem category;

  const _PhraseCard({required this.category});

  @override
  ConsumerState<_PhraseCard> createState() => _PhraseCardState();
}

class _PhraseCardState extends ConsumerState<_PhraseCard> {
  bool _expanded = false;
  late final AudioPlayer _player;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _play(String fileName) async {
    final url =
        'https://studio--leafylib.us-central1.hosted.app/images/$fileName';
    try {
      await _player.stop();
      await _player.setUrl(url);
      await _player.play();
    } catch (_) {
      // ignore for now or add a snackbar if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(
      phraseBookByCategoryProvider(widget.category.title),
    );
    final asyncAll = ref.watch(phraseBookItemsProvider);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  widget.category.icon,
                  size: 32,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.category.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.category.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more),
                  ),
                  onPressed: () => setState(() => _expanded = !_expanded),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: asyncAll.when(
                    loading: () => Text(
                      'Loading…',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    error: (e, _) => Text(
                      'Failed to load',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    data: (_) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final item in items)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: TextButton.icon(
                              onPressed: () => _play(item.url),
                              icon: const Icon(Icons.audiotrack, size: 18),
                              label: Text(
                                item.name,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).colorScheme.primary,
                                side: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),
                        if (items.isEmpty)
                          Text(
                            'No items',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }
}
