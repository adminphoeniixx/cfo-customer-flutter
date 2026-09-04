/// Spacing and radius scale shared across the app, matching the prototype's
/// CSS component shapes (cards, pills, chips, bottom-sheets).
class AppSpace {
  AppSpace._();
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

class AppRadius {
  AppRadius._();
  static const chip = 20.0; // pill-shaped chips / badges
  static const button = 6.0;
  static const card = 12.0;
  static const sheet = 20.0; // bottom sheet top corners
  static const input = 8.0;
  static const small = 6.0;
}
