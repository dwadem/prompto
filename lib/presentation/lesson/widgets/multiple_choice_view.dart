import 'package:flutter/material.dart';

import '../../../domain/entities/exercise.dart';

/// Single-answer check. Reveals correctness + explanation after the user picks,
/// then reports the score (100 correct / 0 wrong) to the lesson.
class MultipleChoiceView extends StatefulWidget {
  const MultipleChoiceView({
    super.key,
    required this.exercise,
    required this.onAnswered,
  });

  final MultipleChoiceExercise exercise;
  final ValueChanged<int> onAnswered;

  @override
  State<MultipleChoiceView> createState() => _MultipleChoiceViewState();
}

class _MultipleChoiceViewState extends State<MultipleChoiceView> {
  int? _selected;
  bool _revealed = false;

  void _check() {
    if (_selected == null) return;
    setState(() => _revealed = true);
    final correct = _selected == widget.exercise.correctIndex;
    widget.onAnswered(correct ? 100 : 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ex = widget.exercise;
    final scheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(ex.prompt, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 20),
        for (var i = 0; i < ex.options.length; i++)
          _OptionTile(
            text: ex.options[i],
            selected: _selected == i,
            revealed: _revealed,
            isCorrect: i == ex.correctIndex,
            onTap: _revealed ? null : () => setState(() => _selected = i),
          ),
        const SizedBox(height: 12),
        if (!_revealed)
          OutlinedButton(
            onPressed: _selected == null ? null : _check,
            child: const Text('Check answer'),
          ),
        if (_revealed)
          Card(
            color: _selected == ex.correctIndex
                ? scheme.primaryContainer
                : scheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                ex.explanation,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.text,
    required this.selected,
    required this.revealed,
    required this.isCorrect,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final bool revealed;
  final bool isCorrect;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Color? border;
    Color? bg;
    if (revealed && isCorrect) {
      border = scheme.primary;
      bg = scheme.primaryContainer.withValues(alpha: 0.4);
    } else if (revealed && selected && !isCorrect) {
      border = scheme.error;
      bg = scheme.errorContainer.withValues(alpha: 0.4);
    } else if (selected) {
      border = scheme.primary;
    }

    return Card(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: border ?? scheme.outlineVariant,
          width: border != null ? 2 : 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(text),
        trailing: revealed && isCorrect
            ? Icon(Icons.check_circle, color: scheme.primary)
            : (revealed && selected && !isCorrect
                ? Icon(Icons.cancel, color: scheme.error)
                : null),
      ),
    );
  }
}
