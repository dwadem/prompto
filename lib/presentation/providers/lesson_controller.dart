import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Runtime state for a single lesson play-through: which step we're on and the
/// per-exercise scores accumulated so far. The widget owns the immutable
/// [Lesson]; this only tracks mutable progress, keyed by lessonId.
class LessonRuntime {
  const LessonRuntime({this.index = 0, this.scores = const {}});

  final int index;
  final Map<String, int> scores;

  int get averageScore {
    if (scores.isEmpty) return 0;
    final sum = scores.values.fold<int>(0, (a, b) => a + b);
    return (sum / scores.length).round();
  }

  LessonRuntime copyWith({int? index, Map<String, int>? scores}) {
    return LessonRuntime(
      index: index ?? this.index,
      scores: scores ?? this.scores,
    );
  }
}

/// Drives forward navigation through a lesson. Auto-disposed so each play-through
/// starts fresh.
class LessonController extends AutoDisposeFamilyNotifier<LessonRuntime, String> {
  @override
  LessonRuntime build(String lessonId) => const LessonRuntime();

  /// Records the score (0–100) for the current exercise.
  void recordScore(String exerciseId, int score) {
    state = state.copyWith(scores: {...state.scores, exerciseId: score});
  }

  /// Advances to the next exercise.
  void next() => state = state.copyWith(index: state.index + 1);
}

final lessonControllerProvider =
    NotifierProvider.autoDispose.family<LessonController, LessonRuntime, String>(
  LessonController.new,
);
