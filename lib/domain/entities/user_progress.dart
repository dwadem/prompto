/// The user's mutable learning record — the sync-critical entity.
///
/// Immutable value object; mutations go through [copyWith] in the repository so
/// state changes stay explicit and unidirectional.
class UserProgress {
  const UserProgress({
    required this.totalXp,
    required this.streakDays,
    required this.lastActiveDay,
    required this.completedLessonIds,
    required this.dailyGoalMinutes,
    required this.freezesAvailable,
    required this.evaluationsUsedToday,
    required this.evaluationsDay,
  });

  final int totalXp;
  final int streakDays;

  /// Date-only (midnight) marker of the last day the user was active.
  final DateTime lastActiveDay;
  final Set<String> completedLessonIds;
  final int dailyGoalMinutes;

  /// "Streak freeze" tokens that protect the streak after a missed day.
  final int freezesAvailable;

  /// Free-tier daily Prompt Lab grading counter (resets each calendar day).
  final int evaluationsUsedToday;
  final DateTime evaluationsDay;

  /// Level derived from XP: 100 XP per level (simple, transparent).
  int get level => (totalXp ~/ 100) + 1;

  int get xpIntoLevel => totalXp % 100;

  int get xpForNextLevel => 100;

  double get levelProgress => xpIntoLevel / xpForNextLevel;

  bool hasCompleted(String lessonId) => completedLessonIds.contains(lessonId);

  UserProgress copyWith({
    int? totalXp,
    int? streakDays,
    DateTime? lastActiveDay,
    Set<String>? completedLessonIds,
    int? dailyGoalMinutes,
    int? freezesAvailable,
    int? evaluationsUsedToday,
    DateTime? evaluationsDay,
  }) {
    return UserProgress(
      totalXp: totalXp ?? this.totalXp,
      streakDays: streakDays ?? this.streakDays,
      lastActiveDay: lastActiveDay ?? this.lastActiveDay,
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      freezesAvailable: freezesAvailable ?? this.freezesAvailable,
      evaluationsUsedToday: evaluationsUsedToday ?? this.evaluationsUsedToday,
      evaluationsDay: evaluationsDay ?? this.evaluationsDay,
    );
  }
}
