abstract final class ApiEndpoints {
  /// Override with `--dart-define=API_BASE_URL=...`
  /// (Android emulator: `http://10.0.2.2:3000/api`).
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3002/api',
  );

  static const sendOtp = '/auth/otp/send';
  static const verifyOtp = '/auth/otp/verify';
  static const refresh = '/auth/refresh';
  static const profile = '/users/me';
  static const tasks = '/tasks';
}
