/// Abstraction over the platform's local-notification capability.
///
/// Keeping this behind an interface means the domain/presentation layers never
/// reference Android `POST_NOTIFICATIONS` or iOS `UNUserNotificationCenter`
/// directly — shipping iOS is an implementation swap, not a refactor.
///
/// TODO: provide a real implementation backed by `flutter_local_notifications`
/// (Android 13+ runtime permission; iOS authorization + APNs entitlement).
abstract interface class ReminderService {
  /// Requests notification permission. Returns whether it was granted.
  Future<bool> requestPermission();

  /// Schedules a gentle daily reminder at the given local time.
  Future<void> scheduleDailyReminder({required int hour, required int minute});

  Future<void> cancelAll();
}

/// No-op implementation used by the prototype so flows are clickable without
/// touching real platform APIs.
class NoopReminderService implements ReminderService {
  const NoopReminderService();

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    // Intentionally empty in the prototype.
  }

  @override
  Future<void> cancelAll() async {}
}
