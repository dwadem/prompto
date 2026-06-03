import 'package:flutter/material.dart';

import '../../../domain/entities/lesson.dart';

enum LessonStatus { done, current, locked }

/// A single lesson node in the skill tree.
class LessonTile extends StatelessWidget {
  const LessonTile({
    super.key,
    required this.lesson,
    required this.status,
    required this.proLocked,
    required this.onTap,
  });

  final Lesson lesson;
  final LessonStatus status;

  /// Requires Pro and the user is Free → tap routes to the paywall.
  final bool proLocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final (Color bg, Color fg, IconData icon) = switch (status) {
      LessonStatus.done => (scheme.primary, scheme.onPrimary, Icons.check),
      LessonStatus.current => (
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
          Icons.play_arrow,
        ),
      LessonStatus.locked => (
          scheme.surfaceContainerHighest,
          scheme.onSurfaceVariant,
          Icons.lock_outline,
        ),
    };

    final interactive = status != LessonStatus.locked || proLocked;

    return Opacity(
      opacity: interactive ? 1 : 0.6,
      child: ListTile(
        onTap: interactive ? onTap : null,
        leading: CircleAvatar(
          backgroundColor: bg,
          foregroundColor: fg,
          child: Icon(proLocked ? Icons.lock_outline : icon),
        ),
        title: Row(
          children: [
            Flexible(child: Text(lesson.title)),
            if (proLocked) ...[
              const SizedBox(width: 8),
              const _ProBadge(),
            ],
          ],
        ),
        subtitle: Text(lesson.subtitle),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('+${lesson.xpReward} XP', style: theme.textTheme.labelMedium),
            Text(
              '${lesson.estimatedMinutes} min',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProBadge extends StatelessWidget {
  const _ProBadge();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'PRO',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: scheme.onTertiaryContainer,
        ),
      ),
    );
  }
}
