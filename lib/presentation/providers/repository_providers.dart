import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/reminder_service.dart';
import '../../data/repositories/fake_curriculum_repository.dart';
import '../../data/repositories/fake_progress_repository.dart';
import '../../data/repositories/fake_prompt_evaluation_repository.dart';
import '../../data/repositories/fake_prompt_library_repository.dart';
import '../../data/repositories/fake_user_repository.dart';
import '../../data/sources/in_memory_store.dart';
import '../../domain/repositories/curriculum_repository.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/repositories/prompt_evaluation_repository.dart';
import '../../domain/repositories/prompt_library_repository.dart';
import '../../domain/repositories/user_repository.dart';

/// Composition root. Every dependency is provided here behind its domain
/// interface, so swapping a fake for a real implementation is a one-line change
/// and the rest of the app is unaffected.
///
/// TODO: when wiring a real backend, override these providers (e.g. in main or
/// a ProviderScope) with Dio/Drift-backed implementations.

final inMemoryStoreProvider = Provider<InMemoryStore>((ref) {
  final store = InMemoryStore();
  ref.onDispose(store.dispose);
  return store;
});

final curriculumRepositoryProvider = Provider<CurriculumRepository>((ref) {
  return FakeCurriculumRepository();
});

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return FakeProgressRepository(ref.watch(inMemoryStoreProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return FakeUserRepository(ref.watch(inMemoryStoreProvider));
});

final promptEvaluationRepositoryProvider =
    Provider<PromptEvaluationRepository>((ref) {
  return FakePromptEvaluationRepository();
});

final promptLibraryRepositoryProvider =
    Provider<PromptLibraryRepository>((ref) {
  return FakePromptLibraryRepository();
});

final reminderServiceProvider = Provider<ReminderService>((ref) {
  // TODO: swap for a flutter_local_notifications-backed implementation.
  return const NoopReminderService();
});
