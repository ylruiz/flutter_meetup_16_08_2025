import 'package:flutter/material.dart';

class SegmentedProgress extends StatelessWidget {
  const SegmentedProgress({
    super.key,
    required this.results,
    required this.currentIndex,
  });
  final List<bool?> results;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = results.length;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: 8,
        child: Row(
          children: List.generate(total, (i) {
            final r = results[i];
            Color color;
            if (r == true) {
              color = theme.colorScheme.primary; // correct => blue
            } else if (r == false) {
              color = theme.colorScheme.outline; // incorrect => dark grey
            } else {
              color =
                  theme.colorScheme.surfaceVariant; // unanswered => light grey
            }
            final BorderRadius radius = i == 0
                ? const BorderRadius.only(
                    topLeft: Radius.circular(999),
                    bottomLeft: Radius.circular(999),
                  )
                : (i == total - 1
                      ? const BorderRadius.only(
                          topRight: Radius.circular(999),
                          bottomRight: Radius.circular(999),
                        )
                      : BorderRadius.zero);
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(color: color, borderRadius: radius),
              ),
            );
          }),
        ),
      ),
    );
  }
}
