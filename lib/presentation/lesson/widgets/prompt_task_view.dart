import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/widgets/state_views.dart';
import '../../../domain/entities/exercise.dart';
import '../../../domain/entities/prompt_evaluation.dart';
import '../../learn/module_visuals.dart';
import '../../providers/prompt_lab_controller.dart';

/// The Prompt Lab: the user writes a real prompt, runs it, and sees a live,
/// rubric-based grade with the (simulated) model output and concrete tips.
/// Reports the best score to the lesson via [onAnswered].
class PromptTaskView extends ConsumerStatefulWidget {
  const PromptTaskView({
    super.key,
    required this.exercise,
    required this.onAnswered,
  });

  final PromptTaskExercise exercise;
  final ValueChanged<int> onAnswered;

  @override
  ConsumerState<PromptTaskView> createState() => _PromptTaskViewState();
}

class _PromptTaskViewState extends ConsumerState<PromptTaskView> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.exercise.starterPrompt);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _exId => widget.exercise.id;

  void _run() {
    FocusScope.of(context).unfocus();
    ref.read(promptLabControllerProvider(_exId).notifier).evaluate(
          task: widget.exercise,
          userPrompt: _controller.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ex = widget.exercise;
    final state = ref.watch(promptLabControllerProvider(_exId));

    // Surface the score to the lesson as soon as a result arrives.
    ref.listen(promptLabControllerProvider(_exId), (_, next) {
      final result = next.evaluation.valueOrNull;
      if (result != null) widget.onAnswered(result.overallScore);
    });

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Icon(Icons.science_outlined, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text('Prompt Lab', style: theme.textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 12),
        Text(ex.prompt, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Card(
          color: theme.colorScheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Task: ${ex.scenario}',
                style: theme.textTheme.bodyMedium),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          minLines: 4,
          maxLines: 8,
          textInputAction: TextInputAction.newline,
          decoration: InputDecoration(
            hintText: 'Write your prompt here…',
            helperText: ex.hint,
            helperMaxLines: 3,
          ),
        ),
        const SizedBox(height: 12),
        if (state.limitReached)
          _LimitReachedCard(
            onUpgrade: () => context.push(Routes.paywall),
            onTryAgain: _run,
            onSkip: () => widget.onAnswered(0),
          )
        else
          state.evaluation.when(
            data: (result) => result == null
                ? FilledButton.icon(
                    onPressed: _run,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Run prompt'),
                  )
                : _ResultView(
                    result: result,
                    onIterate: () {
                      ref
                          .read(promptLabControllerProvider(_exId).notifier)
                          .reset();
                    },
                  ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Running your prompt through the model…'),
                ],
              ),
            ),
            error: (e, _) => ErrorStateView(
              message: e.toString(),
              onRetry: _run,
            ),
          ),
      ],
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.result, required this.onIterate});

  final PromptEvaluation result;
  final VoidCallback onIterate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Overall score.
        Row(
          children: [
            _ScoreBadge(score: result.overallScore),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                result.isPass
                    ? 'Nice prompt! Iterate to push it higher.'
                    : 'Decent start — apply the tips and try again.',
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Rubric breakdown.
        Text('Rubric', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        for (final c in result.criterionScores) _CriterionRow(score: c),
        const SizedBox(height: 20),
        // Simulated model output.
        Text('Model output', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(result.modelOutput),
          ),
        ),
        const SizedBox(height: 20),
        // Suggestions.
        Text('How to improve', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        for (final s in result.suggestions)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.tips_and_updates_outlined),
            title: Text(s),
          ),
        if (result.improvedPrompt != null) ...[
          const SizedBox(height: 8),
          Card(
            color: theme.colorScheme.tertiaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Before → after',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onTertiaryContainer,
                      )),
                  const SizedBox(height: 8),
                  SelectableText(
                    result.improvedPrompt!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: onIterate,
          icon: const Icon(Icons.refresh),
          label: const Text('Iterate on my prompt'),
        ),
      ],
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score});
  final int score;

  @override
  Widget build(BuildContext context) {
    final color = scoreColor(context, score);
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        '$score',
        style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

class _CriterionRow extends StatelessWidget {
  const _CriterionRow({required this.score});
  final CriterionScore score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = scoreColor(context, score.score);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(score.label, style: theme.textTheme.bodyMedium),
              Text('${score.score}',
                  style: theme.textTheme.labelLarge?.copyWith(color: color)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: score.score / 100,
              minHeight: 6,
              color: color,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            score.feedback,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _LimitReachedCard extends StatelessWidget {
  const _LimitReachedCard({
    required this.onUpgrade,
    required this.onTryAgain,
    required this.onSkip,
  });

  final VoidCallback onUpgrade;
  final VoidCallback onTryAgain;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.bolt, color: theme.colorScheme.onTertiaryContainer),
            const SizedBox(height: 8),
            Text(
              'Daily free evaluations used up',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Theory stays free forever. Upgrade to Pro for unlimited live '
              'prompt grading.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onUpgrade,
              child: const Text('See Pro'),
            ),
            const SizedBox(height: 8),
            // Re-run after upgrading (canEvaluate becomes true for Pro).
            OutlinedButton(
              onPressed: onTryAgain,
              child: const Text('Try again'),
            ),
            // Escape hatch so a free user is never hard-blocked mid-lesson.
            TextButton(
              onPressed: onSkip,
              child: const Text('Skip this task'),
            ),
          ],
        ),
      ),
    );
  }
}
