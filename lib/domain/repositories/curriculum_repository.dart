import '../entities/lesson.dart';
import '../entities/skill_module.dart';

/// Read access to the learning content (skill tree, lessons).
///
/// Content is read-mostly and seedable; a future implementation may back this
/// with Drift + a remote content sync.
abstract interface class CurriculumRepository {
  /// All modules ordered by [SkillModule.order].
  Future<List<SkillModule>> getModules();

  /// A single lesson by id, or null if not found.
  Future<Lesson?> getLesson(String lessonId);
}
