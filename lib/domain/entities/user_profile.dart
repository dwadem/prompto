/// Subscription tier. Free is fully usable; Pro lifts the daily evaluation cap
/// and unlocks advanced content (Phase 2+).
enum SubscriptionPlan { free, pro }

/// The (currently anonymous, local) account. Auth is a Phase-2 stub.
class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    required this.plan,
    required this.joinedAt,
  });

  final String id;
  final String displayName;
  final SubscriptionPlan plan;
  final DateTime joinedAt;

  bool get isPro => plan == SubscriptionPlan.pro;

  UserProfile copyWith({String? displayName, SubscriptionPlan? plan}) {
    return UserProfile(
      id: id,
      displayName: displayName ?? this.displayName,
      plan: plan ?? this.plan,
      joinedAt: joinedAt,
    );
  }
}
