import 'package:flutter/material.dart';

/// Celebratory summary shown after the final exercise: XP earned + average
/// score. Kept honest and low-pressure (concept §1, §4.1).
class LessonCompleteView extends StatelessWidget {
  const LessonCompleteView({
    super.key,
    required this.awardedXp,
    required this.averageScore,
    required this.onDone,
  });

  final int awardedXp;
  final int averageScore;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.celebration,
              size: 88, color: theme.colorScheme.primary),
          const SizedBox(height: 24),
          Text('Lesson complete!', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Pill(
                icon: Icons.bolt,
                label: '+$awardedXp XP',
                color: theme.colorScheme.primaryContainer,
                onColor: theme.colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 16),
              _Pill(
                icon: Icons.insights,
                label: 'Avg $averageScore',
                color: theme.colorScheme.tertiaryContainer,
                onColor: theme.colorScheme.onTertiaryContainer,
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onDone,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.label,
    required this.color,
    required this.onColor,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: onColor),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(color: onColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
