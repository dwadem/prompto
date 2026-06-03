import 'package:flutter/material.dart';

import '../../../domain/entities/user_progress.dart';

/// Compact streak / XP / level summary shown atop the Learn screen.
class StatsHeader extends StatelessWidget {
  const StatsHeader({super.key, required this.progress});

  final UserProgress progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _Stat(
                  icon: Icons.local_fire_department,
                  iconColor: Colors.orange,
                  value: '${progress.streakDays}',
                  label: 'day streak',
                ),
                _divider(theme),
                _Stat(
                  icon: Icons.bolt,
                  iconColor: theme.colorScheme.primary,
                  value: '${progress.totalXp}',
                  label: 'XP',
                ),
                _divider(theme),
                _Stat(
                  icon: Icons.workspace_premium_outlined,
                  iconColor: theme.colorScheme.tertiary,
                  value: 'Lv ${progress.level}',
                  label: 'level',
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress.levelProgress,
                minHeight: 8,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${progress.xpIntoLevel}/${progress.xpForNextLevel} XP to next level',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider(ThemeData theme) => Container(
        width: 1,
        height: 36,
        color: theme.colorScheme.outlineVariant,
      );
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.titleLarge),
          Text(
            label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
