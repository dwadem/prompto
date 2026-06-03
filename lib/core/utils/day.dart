/// Date-only helpers for streak math (time-of-day stripped).
abstract final class Day {
  /// Today at local midnight.
  static DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Strips the time component from [dateTime].
  static DateTime from(DateTime dateTime) =>
      DateTime(dateTime.year, dateTime.month, dateTime.day);

  /// Whole-day difference (b - a) ignoring time-of-day.
  static int daysBetween(DateTime a, DateTime b) {
    return from(b).difference(from(a)).inDays;
  }

  static bool isSameDay(DateTime a, DateTime b) => daysBetween(a, b) == 0;
}
