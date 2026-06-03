import '../entities/user_profile.dart';

/// The current account. MVP is a local anonymous profile; auth is a Phase-2
/// concern that will implement this same interface.
abstract interface class UserRepository {
  Future<UserProfile> getCurrentUser();

  Stream<UserProfile> watchCurrentUser();

  /// Prototype upgrade path used by the paywall (no real billing).
  Future<void> upgradeToPro();
}
