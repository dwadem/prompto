import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/exercise.dart';
import '../../domain/entities/prompt_evaluation.dart';
import 'repository_providers.dart';

/// UI state for one Prompt Lab task. Distinguishes idle / loading / data / error
/// and the "free daily limit reached" case, which routes the user to the paywall.
class PromptLabState {
  const PromptLabState({
    this.evaluation = const AsyncValue.data(null),
    this.attempts = 0,
    this.limitReached = false,
  });

  /// null data = idle (not yet run). Otherwise loading/error/result.
  final AsyncValue<PromptEvaluation?> evaluation;
  final int attempts;
  final bool limitReached;

  PromptLabState copyWith({
    AsyncValue<PromptEvaluation?>? evaluation,
    int? attempts,
    bool? limitReached,
  }) {
    return PromptLabState(
      evaluation: evaluation ?? this.evaluation,
      attempts: attempts ?? this.attempts,
      limitReached: limitReached ?? this.limitReached,
    );
  }
}

/// Runs the live grading for a prompt task, enforcing the free-tier daily cap.
/// Keyed by exerciseId so each task has independent state.
class PromptLabController
    extends AutoDisposeFamilyNotifier<PromptLabState, String> {
  @override
  PromptLabState build(String exerciseId) => const PromptLabState();

  Future<void> evaluate({
    required PromptTaskExercise task,
    required String userPrompt,
  }) async {
    final progress = ref.read(progressRepositoryProvider);

    // Enforce the free-tier daily evaluation budget before spending "inference".
    if (!await progress.canEvaluate()) {
      state = state.copyWith(limitReached: true);
      return;
    }

    state = state.copyWith(
      evaluation: const AsyncValue.loading(),
      limitReached: false,
    );

    try {
      final repo = ref.read(promptEvaluationRepositoryProvider);
      final result = await repo.evaluate(task: task, userPrompt: userPrompt);
      await progress.registerEvaluation();
      state = state.copyWith(
        evaluation: AsyncValue.data(result),
        attempts: state.attempts + 1,
      );
    } catch (error, stack) {
      // TODO: map provider errors to user-friendly messages once the real API
      // is wired (rate limits, network, content filters).
      state = state.copyWith(evaluation: AsyncValue.error(error, stack));
    }
  }

  /// Returns to the editing state to iterate on the prompt.
  void reset() {
    state = state.copyWith(evaluation: const AsyncValue.data(null));
  }
}

final promptLabControllerProvider =
    NotifierProvider.autoDispose.family<PromptLabController, PromptLabState, String>(
  PromptLabController.new,
);
