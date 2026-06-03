/// Centralised route paths/names — referenced everywhere instead of raw
/// strings, so renames are safe and deep links are easy to audit.
abstract final class Routes {
  static const onboarding = '/onboarding';
  static const learn = '/learn';
  static const library = '/library';
  static const profile = '/profile';
  static const settings = '/settings';
  static const paywall = '/paywall';

  /// Lesson player. Pass the lessonId as a path parameter.
  static const lesson = '/lesson/:lessonId';
  static String lessonPath(String lessonId) => '/lesson/$lessonId';
}
