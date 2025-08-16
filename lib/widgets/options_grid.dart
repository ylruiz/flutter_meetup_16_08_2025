import 'package:flutter/material.dart';

class OptionsGrid extends StatelessWidget {
  const OptionsGrid({
    super.key,
    required this.options,
    required this.selectedIdx,
    required this.correctIdx,
    required this.answered,
    required this.onSelect,
  });

  final List<String> options;
  final int? selectedIdx;
  final int correctIdx;
  final bool answered;
  final void Function(int) onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const spacing = 16.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        // Force exactly two columns
        final double tileWidth = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: spacing,
          runSpacing: spacing,
          children: List.generate(options.length, (i) {
            final bool isSelected = selectedIdx == i;
            final bool isCorrect = i == correctIdx;

            Color base = theme.colorScheme.primary;
            Color fg = theme.colorScheme.onPrimary;

            if (answered) {
              if (isCorrect) {
                base = Colors.green;
                fg = Colors.white;
              } else if (isSelected) {
                base = Colors.red;
                fg = Colors.white;
              }
            }

            return SizedBox(
              width: tileWidth,
              child: AspectRatio(
                aspectRatio: 4 / 3, // wider than tall
                child: ElevatedButton(
                  onPressed: answered ? null : () => onSelect(i),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: base,
                    foregroundColor: fg,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      options[i],
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
