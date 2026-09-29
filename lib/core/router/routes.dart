abstract final class Routes {
  static const signIn = '/sign-in';
  static const verifyOtp = '/verify-otp';
  static const details = '/details';
  static const home = '/home';
  static const services = '/services';

  /// Reachable without a session.
  static const public = {signIn, verifyOtp};
}
