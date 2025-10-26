import 'package:sajunara_app/services/api/api_service.dart';
import 'dart:convert';

class EventApi {
  final ApiService _apiService = ApiService();

  // ✅ 이벤트 리스트 조회
  Future<List<dynamic>> fetchEventList({Map<String, dynamic>? requestBody}) async {
    try {
      final response = await _apiService.post('/app/api/event/list', body: requestBody);

      print('📡 [리스트] 응답 상태 코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));

        if (decoded is Map<String, dynamic>) {
          bool success = decoded['success'] ?? false;
          String message = decoded['message'] ?? '';

          if (success) {
            if (decoded['data'] != null && decoded['data']['eventListDto'] is List) {
              List<dynamic> eventList = decoded['data']['eventListDto'];
              print('✅ 이벤트 개수: ${eventList.length}');
              return eventList;
            } else {
              print('⚠️ eventListDto가 없거나 List가 아님');
              return [];
            }
          } else {
            throw Exception('API 에러: $message');
          }
        } else {
          throw Exception('예상치 못한 데이터 타입: ${decoded.runtimeType}');
        }
      } else {
        throw Exception('Failed to load events: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ EventApi 에러: $e');
      rethrow;
    }
  }

  // ✅ 이벤트 상세 조회 (eventDto 객체 전달)
  Future<Map<String, dynamic>> fetchEventDetail({required Map<String, dynamic> eventDto}) async {
    try {
      final response = await _apiService.post(
        '/app/api/event/detail',
        body: eventDto, // ✅ eventDto 객체 그대로 전달
      );

      print('📡 [상세] 응답 상태 코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));

        if (decoded is Map<String, dynamic>) {
          bool success = decoded['success'] ?? false;
          String message = decoded['message'] ?? '';

          if (success) {
            if (decoded['data'] != null && decoded['data'] is Map<String, dynamic>) {
              Map<String, dynamic> eventDetail = decoded['data'];
              print('✅ 이벤트 상세 로드 성공: ${eventDetail['eventName']}');
              return eventDetail;
            } else {
              throw Exception('이벤트 데이터가 없습니다');
            }
          } else {
            throw Exception('API 에러: $message');
          }
        } else {
          throw Exception('예상치 못한 데이터 타입: ${decoded.runtimeType}');
        }
      } else {
        throw Exception('Failed to load event detail: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ EventApi 상세 조회 에러: $e');
      rethrow;
    }
  }
}
