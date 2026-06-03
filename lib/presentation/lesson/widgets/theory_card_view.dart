import 'package:flutter/material.dart';

import '../../../domain/entities/exercise.dart';

/// Read-only teaching card. Reports a full score as soon as it's shown, since
/// reading is the only required action (offline-friendly — concept §4.4).
class TheoryCardView extends StatefulWidget {
  const TheoryCardView({
    super.key,
    required this.exercise,
    required this.onAnswered,
  });

  final TheoryExercise exercise;
  final ValueChanged<int> onAnswered;

  @override
  State<TheoryCardView> createState() => _TheoryCardViewState();
}

class _TheoryCardViewState extends State<TheoryCardView> {
  @override
  void initState() {
    super.initState();
    // Reading requires no input; mark ready on next frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onAnswered(100));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ex = widget.exercise;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(ex.prompt, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 16),
        Text(ex.body, style: theme.textTheme.bodyLarge),
        if (ex.example != null) ...[
          const SizedBox(height: 24),
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome,
                          size: 18,
                          color: theme.colorScheme.onPrimaryContainer),
                      const SizedBox(width: 8),
                      Text('Example',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          )),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    ex.example!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
