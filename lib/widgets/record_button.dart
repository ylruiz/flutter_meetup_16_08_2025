import 'package:flutter/material.dart';

class RecordButton extends StatelessWidget {
  const RecordButton({
    super.key,
    required this.isListening,
    required this.onTap,
  });

  final bool isListening;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color bg = isListening ? Colors.red : theme.colorScheme.primary;
    final Color fg = isListening ? Colors.white : theme.colorScheme.onPrimary;

    return Center(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: bg.withAlpha((0.35 * 255).round()),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            isListening ? Icons.stop : Icons.mic,
            color: fg,
            size: 72,
          ),
        ),
      ),
    );
  }
}
