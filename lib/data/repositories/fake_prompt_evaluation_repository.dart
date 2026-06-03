import '../../domain/entities/exercise.dart';
import '../../domain/entities/prompt_evaluation.dart';
import '../../domain/entities/rubric.dart';
import '../../domain/repositories/prompt_evaluation_repository.dart';

/// Deterministic, offline stand-in for the live LLM grader.
///
/// It scores each rubric criterion from cheap textual signals (keyword hits,
/// length, structure) and synthesizes a plausible "model output", concrete
/// suggestions and an improved prompt. This keeps the core flow fully clickable
/// without a backend.
///
/// TODO: replace with an LLM-backed implementation. Suggested seam:
///   1. Send {systemPrompt(rubric), userPrompt} to the provider via Dio.
///   2. Parse the structured grade + generated output.
///   3. Cache by hash(userPrompt + task.id) to limit inference cost (risk §8).
class FakePromptEvaluationRepository implements PromptEvaluationRepository {
  @override
  Future<PromptEvaluation> evaluate({
    required PromptTaskExercise task,
    required String userPrompt,
  }) async {
    // Simulate network/inference latency so the UI shows its loading state.
    await Future<void>.delayed(const Duration(milliseconds: 900));

    final text = userPrompt.toLowerCase();
    final words = text
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .length;

    final scores = <CriterionScore>[];
    final suggestions = <String>[];

    for (final RubricCriterion c in task.rubric.criteria) {
      final hit = c.keywords.any(text.contains);
      // Base score from whether the criterion seems addressed, nudged by effort.
      var raw = hit ? 80 : 35;
      if (words >= 12) raw += 10; // rewards specificity
      if (words < 5) raw -= 15; // too terse to satisfy any rubric
      final score = raw.clamp(0, 100);
      scores.add(
        CriterionScore(
          criterionId: c.id,
          label: c.label,
          score: score,
          feedback: hit
              ? 'Good — ${c.description.toLowerCase()}'
              : 'Missing — ${c.description}',
        ),
      );
      if (!hit) suggestions.add('Add: ${c.description}');
    }

    final overall = _weightedOverall(task.rubric, scores);
    if (words < 5) {
      suggestions.insert(0, 'Your prompt is very short — add specifics.');
    }
    if (suggestions.isEmpty) {
      suggestions.add('Strong prompt. Try tightening it by one more constraint.');
    }

    return PromptEvaluation(
      overallScore: overall,
      criterionScores: scores,
      modelOutput: _simulateModelOutput(task, userPrompt, overall),
      suggestions: suggestions,
      improvedPrompt:
          overall >= 90 ? null : _improvedPrompt(task, userPrompt, scores),
    );
  }

  int _weightedOverall(Rubric rubric, List<CriterionScore> scores) {
    final total = rubric.totalWeight;
    if (total == 0) return 0;
    var sum = 0.0;
    for (final c in rubric.criteria) {
      final s = scores.firstWhere((e) => e.criterionId == c.id);
      sum += s.score * c.weight;
    }
    return (sum / total).round();
  }

  /// A believable "what the model produced" string, varied by quality so the
  /// learner sees the consequence of a weak vs. strong prompt.
  String _simulateModelOutput(
    PromptTaskExercise task,
    String userPrompt,
    int score,
  ) {
    if (score < 50) {
      return 'The model produced a vague, generic answer because the prompt '
          'left too much to interpretation. With more specifics it would have '
          'targeted: "${task.scenario}".';
    }
    if (score < 75) {
      return 'The model produced a reasonable answer to "${task.scenario}", '
          'but drifted on tone/format where your prompt was underspecified.';
    }
    return 'The model produced a focused, on-format response to '
        '"${task.scenario}". Your constraints were respected.';
  }

  /// A simple "after" rewrite that appends the missing pieces — the before/after
  /// teaching moment from the concept (§4.2).
  String _improvedPrompt(
    PromptTaskExercise task,
    String userPrompt,
    List<CriterionScore> scores,
  ) {
    final missing = scores.where((s) => s.score < 70).map((s) => s.label);
    final base = userPrompt.trim().isEmpty
        ? 'Write a response for: ${task.scenario}'
        : userPrompt.trim();
    if (missing.isEmpty) return base;
    return '$base\n\n(Also specify: ${missing.join(', ')}.)';
  }
}
