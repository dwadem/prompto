import 'package:flutter_test/flutter_test.dart';
import 'package:prompto/data/repositories/fake_prompt_evaluation_repository.dart';
import 'package:prompto/domain/entities/exercise.dart';
import 'package:prompto/domain/entities/rubric.dart';

void main() {
  final repo = FakePromptEvaluationRepository();

  const task = PromptTaskExercise(
    id: 't',
    prompt: 'Write a prompt',
    scenario: 'Politely decline a meeting',
    rubric: Rubric(
      criteria: [
        RubricCriterion(
          id: 'clarity',
          label: 'Clarity',
          description: 'States the action.',
          weight: 0.5,
          keywords: ['write', 'decline'],
        ),
        RubricCriterion(
          id: 'tone',
          label: 'Tone',
          description: 'Sets a tone.',
          weight: 0.5,
          keywords: ['polite', 'tone'],
        ),
      ],
    ),
  );

  test('a strong prompt scores higher than a weak one', () async {
    final weak = await repo.evaluate(task: task, userPrompt: 'do it');
    final strong = await repo.evaluate(
      task: task,
      userPrompt:
          'Write a polite three-sentence message to decline the meeting in a '
          'warm, professional tone.',
    );

    expect(strong.overallScore, greaterThan(weak.overallScore));
    expect(strong.criterionScores.length, 2);
  });

  test('weak prompt produces actionable suggestions', () async {
    final result = await repo.evaluate(task: task, userPrompt: 'meeting');
    expect(result.suggestions, isNotEmpty);
    expect(result.improvedPrompt, isNotNull);
  });
}
