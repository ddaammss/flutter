import 'package:sajunara_app/services/api/api_service.dart';
import 'dart:convert';

class StoreApi {
  final ApiService _apiService = ApiService();

  // ✅ Map으로 반환 타입 변경
  Future<Map<String, dynamic>> fetctStoreDetailData({Map<String, dynamic>? requestBody}) async {
    try {
      final response = await _apiService.post('/app/api/store_detail', body: requestBody);

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

  // Future<List<dynamic>> fetchStoreListData({required Map<String, dynamic> requestBody}) async {
  //   try {
  //     final response = await _apiService.post('/app/api/store', body: requestBody);
  //     print('📡 [리스트] 응답 객체: ${response}');
  //     print('📡 [리스트] 응답 상태 코드: ${response.statusCode}');
  //     if (response.statusCode == 200) {
  //       final decoded = json.decode(utf8.decode(response.bodyBytes));

  //       if (decoded is Map<String, dynamic>) {
  //         bool success = decoded['success'] ?? false;
  //         String message = decoded['message'] ?? '';

  //         if (success) {
  //           if (decoded['data'] != null && decoded['data']['storeListDto'] is List) {
  //             List<dynamic> list = decoded['data']['storeListDto'];
  //             print('✅ 입점사 개수: ${list.length}');
  //             return list;
  //           } else {
  //             print('⚠️ eventListDto가 없거나 List가 아님');
  //             return [];
  //           }
  //         } else {
  //           throw Exception('API 에러: $message');
  //         }
  //       } else {
  //         throw Exception('예상치 못한 데이터 타입: ${decoded.runtimeType}');
  //       }
  //     } else {
  //       throw Exception('Failed to load events: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('❌ searchStores 에러: $e');
  //     rethrow;
  //   }
  // }

  Future<Map<String, dynamic>> fetchStoreListData({Map<String, dynamic>? requestBody}) async {
    try {
      final response = await _apiService.post('/app/api/store', body: requestBody);

      print('📡 응답 상태 코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));

        if (decoded is Map<String, dynamic>) {
          // ✅ ApiResponseDto 구조 파싱
          bool success = decoded['success'] ?? false;
          String message = decoded['message'] ?? '';

          //print('✅ 성공 여부: $success');

          if (success) {
            // data 필드에서 실제 데이터 추출
            Map<String, dynamic> data = decoded['data'] ?? {};
            return data;
          } else {
            throw Exception('API 에러: $message');
          }
        } else {
          throw Exception('예상치 못한 데이터 타입: ${decoded.runtimeType}');
        }
      } else {
        //print('❌ 서버 에러: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load main: ${response.statusCode}');
      }
    } catch (e) {
      //print('❌ API 호출 실패: $e');
      rethrow;
    }
  }
}
