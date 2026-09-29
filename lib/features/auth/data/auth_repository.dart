import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/error/error_mapper.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/session_store.dart';
import 'models/auth_response.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(apiClientProvider)),
);

class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  static const _countryCode = '+91';

  /// `9876543210` → `+919876543210`, the format the API expects.
  static String _international(String phone) => '$_countryCode$phone';

  /// Registers the user and sends a 6-digit OTP to [email].
  /// [phone] is 10 digits without +91. Succeeds only on 202 Accepted.
  Future<void> sendOtp({
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post<void>(
        ApiEndpoints.register,
        data: {
          'phoneNumber': _international(phone),
          'email': email,
          'password': password,
        },
      );
      if (res.statusCode != 202) {
        throw AppException(
          'Could not send the OTP. Please try again.',
          statusCode: res.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  /// Verifies the emailed code. On success the user is logged in and the
  /// tokens are returned. Throws [OtpVerificationException].
  Future<AuthResponse> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.verifyOtp,
        data: {'email': email, 'otp': otp},
      );
      return AuthResponse.fromJson(res.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e);
      throw OtpVerificationException(_otpFailureOf(error), error.message);
    }
  }

  /// Signs an existing user in. Returns the tokens and, when the API
  /// includes it, the user.
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      return AuthResponse.fromJson(res.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  /// Emails a new code to [email]. The server always answers 202, whether
  /// or not it actually sent anything. Throws [ResendOtpException].
  Future<void> resendOtp({required String email}) async {
    try {
      await _dio.post<void>(ApiEndpoints.resendOtp, data: {'email': email});
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e);
      final retryAfter = error.details['retryAfterSeconds'];
      throw ResendOtpException(
        error.message,
        retryAfterSeconds: error.statusCode == 429 && retryAfter is num
            ? retryAfter.toInt()
            : null,
      );
    }
  }

  /// Wrong and expired codes are both 400 `BAD_REQUEST`; only the message
  /// tells them apart.
  static OtpFailure _otpFailureOf(AppException error) {
    final message = error.message.toLowerCase();
    return switch (error.statusCode) {
      429 => OtpFailure.tooManyAttempts,
      403 => OtpFailure.suspended,
      400 when message.contains('invalid code') => OtpFailure.invalidCode,
      400 when message.contains('expired') => OtpFailure.expired,
      _ => OtpFailure.other,
    };
  }

  /// `PATCH /api/users/me`. [fullName] is 2–100 characters, trimmed.
  Future<AppUser> updateProfile({required String fullName}) async {
    try {
      final res = await _dio.patch<Map<String, dynamic>>(
        ApiEndpoints.profile,
        data: {'fullName': fullName},
      );
      return AppUser.fromJson(res.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  /// `POST /api/users/me/addresses`. Blank optional fields are left out.
  /// The first address becomes the default.
  Future<UserAddress> addAddress({
    required String flatUnit,
    String? addressLine,
    String? society,
    String? notes,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.addresses,
        data: {
          'flatUnit': flatUnit,
          'addressLine': ?addressLine,
          'society': ?society,
          'notes': ?notes,
        },
      );
      return UserAddress.fromJson(res.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }
}
