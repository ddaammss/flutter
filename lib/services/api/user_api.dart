import 'package:sajunara_app/services/api/api_service.dart';
import 'dart:convert';

class UserApi {
  final ApiService _apiService = ApiService();

  // ✅ Map으로 반환 타입 변경
  Future<Map<String, dynamic>> fetchUserData({Map<String, dynamic>? requestBody}) async {
    try {
      final response = await _apiService.post('/app/api/user/info', body: requestBody);

      print('📡 응답 상태 코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));

        if (decoded is Map<String, dynamic>) {
          bool success = decoded['success'] ?? false;
          String message = decoded['message'] ?? '';

          if (success) {
            Map<String, dynamic> data = decoded['data'] ?? {};
            return data;
          } else {
            throw Exception('API 에러: $message');
          }
        } else {
          throw Exception('예상치 못한 데이터 타입: ${decoded.runtimeType}');
        }
      } else {
        throw Exception('Failed to load main: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchUserPoint({Map<String, dynamic>? requestBody}) async {
    try {
      final response = await _apiService.post('/app/api/user/point', body: requestBody);

      print('📡 응답 상태 코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));

        if (decoded is Map<String, dynamic>) {
          bool success = decoded['success'] ?? false;
          String message = decoded['message'] ?? '';

          if (success) {
            Map<String, dynamic> data = decoded['data'] ?? {};
            return data;
          } else {
            throw Exception('API 에러: $message');
          }
        } else {
          throw Exception('예상치 못한 데이터 타입: ${decoded.runtimeType}');
        }
      } else {
        throw Exception('Failed to load main: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> fetchUserCoupon({Map<String, dynamic>? requestBody}) async {
    try {
      final response = await _apiService.post('/app/api/user/coupon', body: requestBody);

      print('📡 응답 상태 코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));

        if (decoded is Map<String, dynamic>) {
          bool success = decoded['success'] ?? false;
          String message = decoded['message'] ?? '';

          if (success) {
            Map<String, dynamic> data = decoded['data'] ?? {};
            return data;
          } else {
            throw Exception('API 에러: $message');
          }
        } else {
          throw Exception('예상치 못한 데이터 타입: ${decoded.runtimeType}');
        }
      } else {
        throw Exception('Failed to load main: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }


  // ✅ Map으로 반환 타입 변경
  Future<int> updateUserProfile({Map<String, dynamic>? requestBody}) async {
    try {
      final response = await _apiService.post('/app/api/user/update', body: requestBody);

      print('📡 응답 상태 코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));

        if (decoded is Map<String, dynamic>) {
          bool success = decoded['success'] ?? false;
          String message = decoded['message'] ?? '';

          if (success) {
            int data = decoded['data'] ?? {};
            return data;
          } else {
            throw Exception('API 에러: $message');
          }
        } else {
          throw Exception('예상치 못한 데이터 타입: ${decoded.runtimeType}');
        }
      } else {
        throw Exception('Failed to load main: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
