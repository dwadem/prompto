import 'rubric.dart';

/// The kind of step inside a lesson. Modelled as a sealed hierarchy so the UI
/// can switch exhaustively and new types fail the compile until handled.
sealed class Exercise {
  const Exercise({required this.id, required this.prompt});

  /// Stable id, unique within a lesson.
  final String id;

  /// The instruction shown to the learner at the top of the step.
  final String prompt;
}

/// A read-only teaching card (available offline).
class TheoryExercise extends Exercise {
  const TheoryExercise({
    required super.id,
    required super.prompt,
    required this.body,
    this.example,
  });

  final String body;

  /// Optional "good prompt" example to anchor the concept.
  final String? example;
}

/// A single-correct-answer multiple-choice check.
class MultipleChoiceExercise extends Exercise {
  const MultipleChoiceExercise({
    required super.id,
    required super.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final List<String> options;
  final int correctIndex;
  final String explanation;
}

/// The signature exercise: the learner writes a real prompt that is graded live
/// against [rubric] (by an LLM in production, by a heuristic in the prototype).
class PromptTaskExercise extends Exercise {
  const PromptTaskExercise({
    required super.id,
    required super.prompt,
    required this.scenario,
    required this.rubric,
    this.starterPrompt = '',
    this.hint,
  });

  /// Context the learner is writing the prompt for.
  final String scenario;
  final Rubric rubric;

  /// Optional pre-filled text to reduce blank-page friction.
  final String starterPrompt;
  final String? hint;
}
