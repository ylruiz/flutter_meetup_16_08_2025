import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/speech_provider.dart';
import '../widgets/record_button.dart';

class TranslatePage extends ConsumerWidget {
  const TranslatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(speechControllerProvider);
    final controller = ref.read(speechControllerProvider.notifier);

    // Initialize on first build
    if (!state.available) {
      controller.init();
    }

    final theme = Theme.of(context);
    final text = state.text.isEmpty
        ? (state.isListening ? 'Zuhören...' : 'Zum Aufnehmen tippen')
        : state.text;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Make text bigger and vertically centered
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style:
                        theme.textTheme.displaySmall?.copyWith(
                          height: 1.2,
                          fontWeight: FontWeight.w600,
                        ) ??
                        const TextStyle(
                          fontSize: 32,
                          height: 1.2,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
            ),
            RecordButton(
              isListening: state.isListening,
              onTap: controller.toggle,
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
