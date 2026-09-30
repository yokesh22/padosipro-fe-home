abstract final class ApiEndpoints {
  /// Override with `--dart-define=API_BASE_URL=...`
  /// (Android emulator: `http://10.0.2.2:3002`).
  // static const baseUrl = String.fromEnvironment(
  //   'API_BASE_URL',
  //   defaultValue: 'http://localhost:3002',
  // );

  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://padosipro-be-home.onrender.com',
  );

  static const register = '/api/auth/register';
  static const login = '/api/auth/login';
  static const verifyOtp = '/api/auth/verify-email';
  static const resendOtp = '/api/auth/resend-otp';
  static const refresh = '/api/auth/refresh';
  static const profile = '/api/users/me';
  static const addresses = '/api/users/me/addresses';
  static const tasks = '/api/tasks';
  static String task(String id) => '$tasks/$id';
  static String cancelTask(String id) => '$tasks/$id/cancel';
}
