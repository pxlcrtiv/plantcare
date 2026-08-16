import 'package:flutter/material.dart';

/// Floating pill-shaped dock from the reference design (5 destinations,
/// active item = olive circle). Replaces the legacy bottom navigation bar.
class FloatingDock extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<({IconData icon, String label})> destinations;

  const FloatingDock({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = isDark
        ? Theme.of(context).cardColor
        : Colors.white;
    final shadowColor = Theme.of(context).colorScheme.shadow;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: barColor,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < destinations.length; i++)
              _DockItem(
                icon: destinations[i].icon,
                label: destinations[i].label,
                selected: i == currentIndex,
                onTap: () => onTap(i),
                colorScheme: colorScheme,
                isDark: isDark,
              ),
          ],
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final bool isDark;

  const _DockItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.colorScheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected
        ? colorScheme.onPrimary
        : (isDark ? Colors.white70 : const Color(0xFF888888));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: fg),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}