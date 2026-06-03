import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/async_value_widget.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/lesson.dart';
import '../providers/app_providers.dart';
import '../providers/lesson_controller.dart';
import '../providers/repository_providers.dart';
import 'lesson_complete_view.dart';
import 'widgets/multiple_choice_view.dart';
import 'widgets/prompt_task_view.dart';
import 'widgets/theory_card_view.dart';

/// Orchestrates a single lesson play-through: renders the current exercise,
/// gates the Continue button on an answer, then awards XP and updates the streak
/// on completion via the [ProgressRepository].
class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  /// Score for the currently displayed exercise; null until the user answers.
  int? _currentScore;

  // Completion state.
  bool _completing = false;
  bool _completed = false;
  int _awardedXp = 0;
  int _finalScore = 0;

  Future<void> _onContinue(Lesson lesson) async {
    final controller = ref.read(lessonControllerProvider(lesson.id).notifier);
    final runtime = ref.read(lessonControllerProvider(lesson.id));
    final exercise = lesson.exercises[runtime.index];

    controller.recordScore(exercise.id, _currentScore ?? 0);

    final isLast = runtime.index >= lesson.exercises.length - 1;
    if (isLast) {
      await _finish(lesson);
    } else {
      controller.next();
      setState(() => _currentScore = null);
    }
  }

  Future<void> _finish(Lesson lesson) async {
    setState(() => _completing = true);
    final average = ref.read(lessonControllerProvider(lesson.id)).averageScore;
    final awarded = await ref.read(progressRepositoryProvider).completeLesson(
          lessonId: lesson.id,
          baseXp: lesson.xpReward,
          scorePercent: average,
        );
    if (!mounted) return;
    setState(() {
      _completing = false;
      _completed = true;
      _awardedXp = awarded;
      _finalScore = average;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lessonAsync = ref.watch(lessonProvider(widget.lessonId));

    return Scaffold(
      body: SafeArea(
        child: AsyncValueWidget(
          value: lessonAsync,
          onRetry: () => ref.invalidate(lessonProvider(widget.lessonId)),
          data: (lesson) {
            if (lesson == null) {
              return const Center(child: Text('Lesson not found'));
            }
            if (_completing) {
              return const Center(child: CircularProgressIndicator());
            }
            if (_completed) {
              return LessonCompleteView(
                awardedXp: _awardedXp,
                averageScore: _finalScore,
                onDone: () => context.pop(),
              );
            }
            return _buildPlayer(lesson);
          },
        ),
      ),
    );
  }

  Widget _buildPlayer(Lesson lesson) {
    final runtime = ref.watch(lessonControllerProvider(lesson.id));
    final index = runtime.index.clamp(0, lesson.exercises.length - 1);
    final exercise = lesson.exercises[index];
    final progress = (index + 1) / lesson.exercises.length;
    final isLast = index >= lesson.exercises.length - 1;

    return Column(
      children: [
        // Top bar: close + step progress.
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.pop(),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text('${index + 1}/${lesson.exercises.length}'),
            ],
          ),
        ),
        Expanded(
          child: _exerciseView(exercise),
        ),
        // Continue bar.
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed:
                  _currentScore == null ? null : () => _onContinue(lesson),
              child: Text(isLast ? 'Finish lesson' : 'Continue'),
            ),
          ),
        ),
      ],
    );
  }

  /// Exhaustive switch over the sealed [Exercise] type — adding a new exercise
  /// kind will fail the compile here until it's handled.
  Widget _exerciseView(Exercise exercise) {
    // Key by id so per-exercise widget state resets between steps.
    final key = ValueKey(exercise.id);
    void onAnswered(int score) {
      if (!mounted) return;
      setState(() => _currentScore = score);
    }

    return switch (exercise) {
      TheoryExercise() => TheoryCardView(
          key: key,
          exercise: exercise,
          onAnswered: onAnswered,
        ),
      MultipleChoiceExercise() => MultipleChoiceView(
          key: key,
          exercise: exercise,
          onAnswered: onAnswered,
        ),
      PromptTaskExercise() => PromptTaskView(
          key: key,
          exercise: exercise,
          onAnswered: onAnswered,
        ),
    };
  }
}
