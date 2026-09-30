abstract final class Routes {
  static const signUp = '/sign-up';
  static const signIn = '/sign-in';
  static const verifyOtp = '/verify-otp';
  static const details = '/details';
  static const home = '/home';
  static const services = '/services';
  static const requestWhen = '/services/when';
  static const requestDetails = '/services/details';
  static const account = '/account';

  /// Reachable without a session.
  static const public = {signUp, signIn, verifyOtp};
}
