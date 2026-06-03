import '../entities/exercise.dart';
import '../entities/prompt_evaluation.dart';

/// Grades a user's prompt against a task rubric.
///
/// This is the seam for the product's core feature. The prototype ships a
/// deterministic heuristic implementation; production swaps in an LLM-backed
/// one (e.g. via Dio + a provider-agnostic gateway) without touching the UI.
abstract interface class PromptEvaluationRepository {
  Future<PromptEvaluation> evaluate({
    required PromptTaskExercise task,
    required String userPrompt,
  });
}
