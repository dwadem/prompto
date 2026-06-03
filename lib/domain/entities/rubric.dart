/// A single graded dimension of a prompt task (e.g. "Clarity", "Context").
///
/// [weight] values across a [Rubric] are normalized when scoring, so they do
/// not need to sum to 1.0.
///
/// Pure Dart — no Flutter imports, so the domain layer stays platform-neutral.
class RubricCriterion {
  const RubricCriterion({
    required this.id,
    required this.label,
    required this.description,
    required this.weight,
    this.keywords = const <String>[],
  });

  final String id;
  final String label;
  final String description;
  final double weight;

  /// Lightweight signal used by the heuristic fake grader to detect whether the
  /// user addressed this criterion. The real LLM grader will ignore this.
  final List<String> keywords;
}

/// The grading contract for a prompt-task exercise.
class Rubric {
  const Rubric({required this.criteria});

  final List<RubricCriterion> criteria;

  double get totalWeight =>
      criteria.fold<double>(0, (sum, c) => sum + c.weight);
}
