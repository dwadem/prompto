import 'exercise.dart';

/// A 2–5 minute unit of learning, composed of ordered [exercises].
class Lesson {
  const Lesson({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.subtitle,
    required this.exercises,
    required this.xpReward,
    this.estimatedMinutes = 3,
    this.isPro = false,
  });

  final String id;
  final String moduleId;
  final String title;
  final String subtitle;
  final List<Exercise> exercises;

  /// XP granted on completion (modulated by performance — see ProgressRepository).
  final int xpReward;
  final int estimatedMinutes;

  /// Pro-gated content (Phase 2+). Free lessons keep [isPro] false.
  final bool isPro;
}
