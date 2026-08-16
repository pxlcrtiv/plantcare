import 'package:flutter/material.dart';

/// Segmented pill row from the reference design (e.g. Indoor / Outdoor /
/// Both). Selected pill = olive fill with dark text; unselected = white
/// (or dark surface) with a subtle border.
class PillTabRow extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const PillTabRow({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedBg = isDark ? Theme.of(context).cardColor : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : const Color(0xFFE4E4DC);

    return Row(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: i == selectedIndex
                    ? colorScheme.primary
                    : unselectedBg,
                borderRadius: BorderRadius.circular(24),
                border: i == selectedIndex
                    ? null
                    : Border.all(color: borderColor, width: 1),
              ),
              child: Text(
                options[i],
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight:
                      i == selectedIndex ? FontWeight.w600 : FontWeight.w500,
                  color: i == selectedIndex
                      ? colorScheme.onPrimary
                      : (isDark
                          ? Colors.white70
                          : const Color(0xFF888888)),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}