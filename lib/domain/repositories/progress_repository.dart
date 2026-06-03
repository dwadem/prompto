import '../entities/user_progress.dart';

/// Reads and mutates the user's [UserProgress].
///
/// Progress is exposed as a [Stream] so streak/XP changes propagate reactively
/// to every screen. The fake implementation keeps it in memory; a real one
/// would persist locally (Drift) and sync remotely.
abstract interface class ProgressRepository {
  /// Current value, loaded once.
  Future<UserProgress> getProgress();

  /// Live updates (emits the current value immediately on listen).
  Stream<UserProgress> watchProgress();

  /// Records a finished lesson: awards XP scaled by [scorePercent] (0–100),
  /// updates the streak, and marks the lesson complete. Returns the XP awarded.
  Future<int> completeLesson({
    required String lessonId,
    required int baseXp,
    required int scorePercent,
  });

  /// Whether the user may run another live grading today (free-tier cap).
  Future<bool> canEvaluate();

  /// Consumes one daily evaluation credit (no-op for Pro).
  Future<void> registerEvaluation();

  Future<void> setDailyGoalMinutes(int minutes);
}
