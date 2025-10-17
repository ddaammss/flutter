import 'package:sajunara_app/services/api/api_service.dart';
import 'dart:convert';

class MainApi {
  final ApiService _apiService = ApiService();

  // ✅ Map으로 반환 타입 변경
  Future<Map<String, dynamic>> fetMainData({Map<String, dynamic>? requestBody}) async {
    try {
      final response = await _apiService.post('/app/api/main', body: requestBody);

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
