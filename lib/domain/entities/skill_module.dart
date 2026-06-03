import 'lesson.dart';

/// Icon identity for a module. Kept as a domain enum (not a Flutter IconData)
/// so the domain layer stays platform-neutral; presentation maps it to an icon.
enum ModuleIcon { basics, context, fewShot, structure, reasoning, verification }

/// A node in the skill tree grouping related [lessons].
class SkillModule {
  const SkillModule({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.order,
    required this.lessons,
    this.isPro = false,
  });

  final String id;
  final String title;
  final String description;
  final ModuleIcon icon;

  /// Position in the learning path (lower unlocks first).
  final int order;
  final List<Lesson> lessons;
  final bool isPro;
}
