import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  /// Sends a 6-digit OTP to [email]. [phone] is 10 digits without +91.
  Future<void> sendOtp({required String phone, required String email}) async {
    try {
      await _dio.post<void>(
        ApiEndpoints.sendOtp,
        data: {'phone': phone, 'email': email},
      );
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  Future<AuthResponse> verifyOtp({
    required String phone,
    required String email,
    required String otp,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.verifyOtp,
        data: {'phone': phone, 'email': email, 'otp': otp},
      );
      return AuthResponse.fromJson(res.data!);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  Future<AppUser> completeProfile({
    required String name,
    String? address,
    String? society,
    String? flat,
    String? notes,
  }) async {
    try {
      final res = await _dio.put<Map<String, dynamic>>(
        ApiEndpoints.profile,
        data: {
          'name': name,
          'address': ?address,
          'society': ?society,
          'flat': ?flat,
          'notes': ?notes,
        },
      );
      return AppUser.fromJson(res.data!);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }
}
