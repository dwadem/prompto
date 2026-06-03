import 'package:flutter_test/flutter_test.dart';
import 'package:prompto/data/repositories/fake_progress_repository.dart';
import 'package:prompto/data/sources/in_memory_store.dart';

void main() {
  late InMemoryStore store;
  late FakeProgressRepository repo;

  setUp(() {
    store = InMemoryStore();
    repo = FakeProgressRepository(store);
  });

  tearDown(() => store.dispose());

  test('completing a lesson awards XP scaled by score and marks it done',
      () async {
    final before = await repo.getProgress();
    final awarded = await repo.completeLesson(
      lessonId: 'l_new',
      baseXp: 20,
      scorePercent: 100,
    );
    final after = await repo.getProgress();

    expect(awarded, greaterThan(0));
    expect(after.totalXp, before.totalXp + awarded);
    expect(after.hasCompleted('l_new'), isTrue);
  });

  test('higher score yields more XP for the same base', () async {
    final low = await FakeProgressRepository(InMemoryStore())
        .completeLesson(lessonId: 'a', baseXp: 20, scorePercent: 40);
    final high = await FakeProgressRepository(InMemoryStore())
        .completeLesson(lessonId: 'a', baseXp: 20, scorePercent: 100);
    expect(high, greaterThan(low));
  });

  test('free tier blocks evaluations after the daily cap', () async {
    expect(await repo.canEvaluate(), isTrue);
    for (var i = 0; i < kFreeDailyEvaluations; i++) {
      await repo.registerEvaluation();
    }
    expect(await repo.canEvaluate(), isFalse);
  });
}
