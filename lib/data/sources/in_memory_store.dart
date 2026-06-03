import 'dart:async';

import '../../domain/entities/user_profile.dart';
import '../../domain/entities/user_progress.dart';
import '../../core/utils/day.dart';

/// In-memory backing store for the prototype's mutable state (progress + user).
///
/// Holds the single source of truth and broadcasts changes via streams so the
/// UI updates reactively. It is intentionally simple.
///
/// TODO: replace with a Drift-backed store (same shape: load + watch + write).
class InMemoryStore {
  InMemoryStore() {
    final today = Day.today();
    _progress = UserProgress(
      totalXp: 120,
      streakDays: 3,
      lastActiveDay: today.subtract(const Duration(days: 1)),
      completedLessonIds: <String>{'l_basics_1'},
      dailyGoalMinutes: 10,
      freezesAvailable: 1,
      evaluationsUsedToday: 0,
      evaluationsDay: today,
    );
    _user = UserProfile(
      id: 'local-user',
      displayName: 'Learner',
      plan: SubscriptionPlan.free,
      joinedAt: today.subtract(const Duration(days: 3)),
    );
    _progressController.add(_progress);
    _userController.add(_user);
  }

  late UserProgress _progress;
  late UserProfile _user;

  final StreamController<UserProgress> _progressController =
      StreamController<UserProgress>.broadcast();
  final StreamController<UserProfile> _userController =
      StreamController<UserProfile>.broadcast();

  UserProgress get progress => _progress;
  UserProfile get user => _user;

  Stream<UserProgress> get progressStream => _progressController.stream;
  Stream<UserProfile> get userStream => _userController.stream;

  void setProgress(UserProgress value) {
    _progress = value;
    _progressController.add(value);
  }

  void setUser(UserProfile value) {
    _user = value;
    _userController.add(value);
  }

  void dispose() {
    _progressController.close();
    _userController.close();
  }
}
