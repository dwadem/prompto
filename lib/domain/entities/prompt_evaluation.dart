/// Score for one rubric criterion, produced by grading a prompt.
class CriterionScore {
  const CriterionScore({
    required this.criterionId,
    required this.label,
    required this.score,
    required this.feedback,
  });

  final String criterionId;
  final String label;

  /// 0–100.
  final int score;
  final String feedback;
}

/// The result of grading a user's prompt against a task rubric.
///
/// Returned by [PromptEvaluationRepository]; transient and cacheable by
/// hash(prompt + taskId) to limit inference cost.
class PromptEvaluation {
  const PromptEvaluation({
    required this.overallScore,
    required this.criterionScores,
    required this.modelOutput,
    required this.suggestions,
    this.improvedPrompt,
  });

  /// Weighted 0–100 across all criteria.
  final int overallScore;
  final List<CriterionScore> criterionScores;

  /// What the (simulated) model produced for this prompt.
  final String modelOutput;

  /// Concrete, actionable tips.
  final List<String> suggestions;

  /// A "after" rewrite for the before/after teaching moment.
  final String? improvedPrompt;

  bool get isPass => overallScore >= 70;
}
