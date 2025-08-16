import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/game_provider.dart';
import '../widgets/options_grid.dart';
import '../widgets/play_button.dart';
import '../widgets/segmented_progress.dart';

class GamePage extends ConsumerWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameControllerDefaultProvider);
    final controller = ref.read(gameControllerDefaultProvider.notifier);

    if (state.finished) {
      final total = state.results.length;
      final correct = state.results.where((r) => r == true).length;
      return SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.emoji_events,
                  size: 96,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Ergebnis',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '$correct / $total richtig',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: controller.restart,
                  child: const Text('Neu starten'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SegmentedProgress(
              results: state.results,
              currentIndex: state.currentIndex,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PlayButton(onPressed: controller.playCurrent),
                    const SizedBox(height: 32),
                    OptionsGrid(
                      options: state.current.answers
                          .map((a) => a.text)
                          .toList(),
                      selectedIdx: state.selectedIdx,
                      correctIdx: state.current.answers.indexWhere(
                        (a) => a.isCorrect,
                      ),
                      answered: state.answered,
                      onSelect: controller.selectAndNext,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
