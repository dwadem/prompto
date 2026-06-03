import '../../domain/entities/lesson.dart';
import '../../domain/entities/skill_module.dart';
import '../../domain/repositories/curriculum_repository.dart';
import '../sources/sample_data.dart';

/// In-memory curriculum backed by [SampleData].
///
/// Small artificial delays simulate async I/O so the UI exercises its
/// loading states. TODO: connect a real content API via Dio, or Drift seed.
class FakeCurriculumRepository implements CurriculumRepository {
  final List<SkillModule> _modules = SampleData.modules();

  @override
  Future<List<SkillModule>> getModules() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final sorted = [..._modules]..sort((a, b) => a.order.compareTo(b.order));
    return sorted;
  }

  @override
  Future<Lesson?> getLesson(String lessonId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    for (final module in _modules) {
      for (final lesson in module.lessons) {
        if (lesson.id == lessonId) return lesson;
      }
    }
    return null;
  }
}
