import '../../core/utils/day.dart';
import '../../domain/entities/user_progress.dart';
import '../../domain/repositories/progress_repository.dart';
import '../sources/in_memory_store.dart';

/// Free-tier cap on live gradings per day (assumption — see analysis).
const int kFreeDailyEvaluations = 5;

/// Progress logic over the [InMemoryStore]: XP awards, streak rollover and the
/// daily evaluation counter. Pure value transitions via [UserProgress.copyWith].
class FakeProgressRepository implements ProgressRepository {
  FakeProgressRepository(this._store);

  final InMemoryStore _store;

  @override
  Future<UserProgress> getProgress() async => _store.progress;

  @override
  Stream<UserProgress> watchProgress() async* {
    yield _store.progress; // emit current value immediately
    yield* _store.progressStream;
  }

  @override
  Future<int> completeLesson({
    required String lessonId,
    required int baseXp,
    required int scorePercent,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final current = _store.progress;

    // XP scales with quality (50–120% of base), rewarding skill over clicking.
    final awarded = (baseXp * (0.5 + (scorePercent / 100) * 0.7)).round();

    final completed = {...current.completedLessonIds, lessonId};
    final next = current
        .copyWith(
          totalXp: current.totalXp + awarded,
          completedLessonIds: completed,
        )
        .let(_applyStreak);

    _store.setProgress(next);
    return awarded;
  }

  /// Advances the streak based on the gap since [UserProgress.lastActiveDay].
  /// Same day → unchanged; +1 day → continue; longer gap → a freeze saves it,
  /// otherwise it resets to 1.
  UserProgress _applyStreak(UserProgress p) {
    final today = Day.today();
    final gap = Day.daysBetween(p.lastActiveDay, today);
    if (gap == 0) {
      return p.copyWith(lastActiveDay: today);
    }
    if (gap == 1) {
      return p.copyWith(streakDays: p.streakDays + 1, lastActiveDay: today);
    }
    if (p.freezesAvailable > 0) {
      return p.copyWith(
        freezesAvailable: p.freezesAvailable - 1,
        streakDays: p.streakDays + 1,
        lastActiveDay: today,
      );
    }
    return p.copyWith(streakDays: 1, lastActiveDay: today);
  }

  @override
  Future<bool> canEvaluate() async {
    if (_store.user.isPro) return true;
    final p = _refreshedEvalCounter();
    return p.evaluationsUsedToday < kFreeDailyEvaluations;
  }

  @override
  Future<void> registerEvaluation() async {
    if (_store.user.isPro) return;
    final p = _refreshedEvalCounter();
    _store.setProgress(
      p.copyWith(evaluationsUsedToday: p.evaluationsUsedToday + 1),
    );
  }

  /// Resets the daily counter when the calendar day has rolled over.
  UserProgress _refreshedEvalCounter() {
    final p = _store.progress;
    final today = Day.today();
    if (!Day.isSameDay(p.evaluationsDay, today)) {
      final reset =
          p.copyWith(evaluationsUsedToday: 0, evaluationsDay: today);
      _store.setProgress(reset);
      return reset;
    }
    return p;
  }

  @override
  Future<void> setDailyGoalMinutes(int minutes) async {
    _store.setProgress(_store.progress.copyWith(dailyGoalMinutes: minutes));
  }
}

/// Tiny pipe helper to keep the transition above readable.
extension _Let<T> on T {
  R let<R>(R Function(T) f) => f(this);
}
