import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/lesson.dart';
import '../../domain/entities/skill_module.dart';
import '../../domain/entities/prompt_template.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/user_progress.dart';
import 'repository_providers.dart';

/// Reactive app state derived from the repositories. Screens watch these and
/// render loading/error/data uniformly via [AsyncValue].

/// Live user progress (XP, streak, completion). Streamed so every screen stays
/// in sync after a lesson completes.
final progressProvider = StreamProvider<UserProgress>((ref) {
  return ref.watch(progressRepositoryProvider).watchProgress();
});

/// Current account (free/pro).
final userProvider = StreamProvider<UserProfile>((ref) {
  return ref.watch(userRepositoryProvider).watchCurrentUser();
});

/// The skill tree.
final modulesProvider = FutureProvider<List<SkillModule>>((ref) {
  return ref.watch(curriculumRepositoryProvider).getModules();
});

/// A single lesson, loaded for the player. Family-keyed by lessonId.
final lessonProvider = FutureProvider.family<Lesson?, String>((ref, lessonId) {
  return ref.watch(curriculumRepositoryProvider).getLesson(lessonId);
});

/// Prompt-template library.
final templatesProvider = FutureProvider<List<PromptTemplate>>((ref) {
  return ref.watch(promptLibraryRepositoryProvider).getTemplates();
});

/// App theme mode, toggled from settings. Kept in memory for the prototype.
/// TODO: persist via shared_preferences / Drift settings table.
final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void set(ThemeMode mode) => state = mode;
}

/// Whether onboarding has been completed this run (prototype: in-memory).
/// TODO: persist a "seen onboarding" flag locally.
final onboardingDoneProvider =
    NotifierProvider<OnboardingNotifier, bool>(OnboardingNotifier.new);

class OnboardingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void complete() => state = true;
}
